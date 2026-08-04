extends XROrigin3D
class_name Player

## Hexfall player controller: VR locomotion, snap-turn,
## ability casting, essence pool, health, shield, buffs, score.

@export var max_health: float = 100.0
@export var max_essence: float = 100.0
@export var essence_regen_per_sec: float = 6.0
@export var move_speed: float = 2.5
@export var snap_turn_angle: float = 30.0

## Ability slots — assigned in Inspector / Player.tscn
@export var right_hand_ability: Ability   ## Right trigger
@export var left_hand_ability: Ability    ## Left trigger
@export var ultimate_ability: Ability     ## Right A/X button
@export var secondary_ability: Ability   ## Left B/Y button

@onready var head: XRCamera3D        = $XRCamera3D
@onready var left_controller: XRController3D  = $LeftController
@onready var right_controller: XRController3D = $RightController
@onready var body: CharacterBody3D   = get_parent() as CharacterBody3D

var health: float
var essence: float
var shield: float = 0.0
var _shield_timer: float = 0.0
var _buffs: Dictionary = {}
var _snap_cooldown: float = 0.0
var score: int = 0

signal health_changed(current: float, max_val: float)
signal essence_changed(current: float, max_val: float)
signal shield_changed(current: float)
signal score_changed(new_score: int)
signal died
signal ability_used(slot: String, cooldown_fraction: float)

func _ready() -> void:
	health  = max_health
	essence = max_essence
	if left_controller:
		left_controller.button_pressed.connect(_on_left_button)
	if right_controller:
		right_controller.button_pressed.connect(_on_right_button)

func _process(delta: float) -> void:
	essence = min(max_essence, essence + essence_regen_per_sec * delta)
	essence_changed.emit(essence, max_essence)

	for ab in [right_hand_ability, left_hand_ability, ultimate_ability, secondary_ability]:
		if ab:
			ab.tick_cooldown(delta)

	if shield > 0.0:
		_shield_timer -= delta
		if _shield_timer <= 0.0:
			shield = 0.0
			shield_changed.emit(0.0)

	_tick_buffs(delta)
	_handle_locomotion(delta)
	_handle_snap_turn(delta)

func _handle_locomotion(delta: float) -> void:
	if not left_controller or not body:
		return
	var input_vec: Vector2 = left_controller.get_vector2("primary")
	if input_vec.length() < 0.1:
		body.velocity.x = move_toward(body.velocity.x, 0.0, move_speed)
		body.velocity.z = move_toward(body.velocity.z, 0.0, move_speed)
	else:
		var forward := -head.global_transform.basis.z
		forward.y = 0.0; forward = forward.normalized()
		var right := head.global_transform.basis.x
		right.y = 0.0; right = right.normalized()
		var speed := move_speed * get_speed_multiplier()
		var move_dir := (forward * input_vec.y + right * input_vec.x)
		body.velocity.x = move_dir.x * speed
		body.velocity.z = move_dir.z * speed

	body.velocity.y = 0.0 if body.is_on_floor() else body.velocity.y - 9.8 * delta
	body.move_and_slide()

func _handle_snap_turn(delta: float) -> void:
	_snap_cooldown = max(0.0, _snap_cooldown - delta)
	if _snap_cooldown > 0.0 or not right_controller:
		return
	var rx: float = right_controller.get_vector2("primary").x
	if abs(rx) > 0.7:
		body.global_rotation.y -= deg_to_rad(snap_turn_angle) * sign(rx)
		_snap_cooldown = 0.35

func _on_left_button(name: String) -> void:
	match name:
		"trigger_click": _cast(left_hand_ability,  left_controller,  "left")
		"by_button":     _cast(secondary_ability,  left_controller,  "secondary")

func _on_right_button(name: String) -> void:
	match name:
		"trigger_click": _cast(right_hand_ability, right_controller, "right")
		"ax_button":     _cast(ultimate_ability,   right_controller, "ultimate")

func _cast(ability: Ability, controller: XRController3D, slot: String) -> void:
	if ability == null or controller == null:
		return
	if not ability.is_ready():
		return
	if essence < ability.essence_cost:
		return
	essence -= ability.essence_cost
	ability.start_cooldown()
	ability.execute(self, controller.global_position, -controller.global_transform.basis.z)
	ability_used.emit(slot, ability.cooldown_fraction())

func take_damage(amount: float, source: Node = null) -> void:
	if health <= 0.0:
		return
	var remaining := amount
	if shield > 0.0:
		var absorbed := min(shield, remaining)
		shield -= absorbed; remaining -= absorbed
		shield_changed.emit(shield)
	health = max(0.0, health - remaining)
	health_changed.emit(health, max_health)
	if health <= 0.0:
		died.emit()

func apply_shield(amount: float, duration: float) -> void:
	shield = amount; _shield_timer = duration
	shield_changed.emit(shield)

func restore_essence(amount: float) -> void:
	essence = min(max_essence, essence + amount)
	essence_changed.emit(essence, max_essence)

func apply_heal_over_time(amount: float, duration: float) -> void:
	_heal_ticks(max(1, int(duration)), amount / float(max(1, int(duration))))

func _heal_ticks(count: int, per_tick: float) -> void:
	if count <= 0 or not is_inside_tree():
		return
	await get_tree().create_timer(1.0).timeout
	if not is_inside_tree():
		return
	health = min(max_health, health + per_tick)
	health_changed.emit(health, max_health)
	_heal_ticks(count - 1, per_tick)

func apply_buff(buff_name: String, multiplier: float, duration: float) -> void:
	_buffs[buff_name] = {"duration": duration, "multiplier": multiplier}

func get_damage_multiplier() -> float:
	return _buffs["damage_multiplier"]["multiplier"] if _buffs.has("damage_multiplier") else 1.0

func get_speed_multiplier() -> float:
	return _buffs["speed_multiplier"]["multiplier"] if _buffs.has("speed_multiplier") else 1.0

func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)

func _tick_buffs(delta: float) -> void:
	for key in _buffs.keys():
		_buffs[key]["duration"] -= delta
		if _buffs[key]["duration"] <= 0.0:
			_buffs.erase(key)
