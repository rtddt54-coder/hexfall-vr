extends XROrigin3D
class_name Player

## Hexfall player controller: VR locomotion via thumbstick, ability
## casting bound to controller triggers/buttons, essence resource,
## health, shield, and buff handling.

@export var max_health: float = 100.0
@export var max_essence: float = 100.0
@export var essence_regen_per_sec: float = 6.0
@export var move_speed: float = 2.5

@export var right_hand_ability: Ability
@export var left_hand_ability: Ability
@export var ultimate_ability: Ability

@onready var head: XRCamera3D = $XRCamera3D
@onready var left_controller: XRController3D = $LeftController
@onready var right_controller: XRController3D = $RightController
@onready var body: CharacterBody3D = get_parent() as CharacterBody3D

var health: float
var essence: float
var shield: float = 0.0
var _shield_timer: float = 0.0
var _buffs: Dictionary = {}

signal health_changed(current: float, max: float)
signal essence_changed(current: float, max: float)
signal died

func _ready() -> void:
	health = max_health
	essence = max_essence

	if left_controller:
		left_controller.button_pressed.connect(_on_left_button.bind())
	if right_controller:
		right_controller.button_pressed.connect(_on_right_button.bind())

func _process(delta: float) -> void:
	essence = min(max_essence, essence + essence_regen_per_sec * delta)
	essence_changed.emit(essence, max_essence)

	if right_hand_ability:
		right_hand_ability.tick_cooldown(delta)
	if left_hand_ability:
		left_hand_ability.tick_cooldown(delta)
	if ultimate_ability:
		ultimate_ability.tick_cooldown(delta)

	if shield > 0.0:
		_shield_timer -= delta
		if _shield_timer <= 0.0:
			shield = 0.0

	_tick_buffs(delta)
	_handle_locomotion(delta)

func _handle_locomotion(delta: float) -> void:
	if not left_controller or not body:
		return
	var input_vec: Vector2 = left_controller.get_vector2("primary")
	if input_vec.length() < 0.1:
		return
	var forward := -head.global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()
	var right := head.global_transform.basis.x
	right.y = 0
	right = right.normalized()
	var move_dir := (forward * -input_vec.y + right * input_vec.x)
	body.velocity.x = move_dir.x * move_speed
	body.velocity.z = move_dir.z * move_speed
	body.move_and_slide()

func _on_left_button(name: String) -> void:
	if name == "trigger_click":
		_cast(left_hand_ability, left_controller)

func _on_right_button(name: String) -> void:
	if name == "trigger_click":
		_cast(right_hand_ability, right_controller)
	elif name == "ax_button": # A/X button reserved for ultimate
		_cast(ultimate_ability, right_controller)

func _cast(ability: Ability, controller: XRController3D) -> void:
	if ability == null or controller == null:
		return
	if not ability.is_ready():
		return
	if essence < ability.essence_cost:
		return
	essence -= ability.essence_cost
	ability.start_cooldown()
	var origin := controller.global_position
	var direction := -controller.global_transform.basis.z
	ability.execute(self, origin, direction)

func take_damage(amount: float, source: Node = null) -> void:
	var remaining := amount
	if shield > 0.0:
		var absorbed: float = min(shield, remaining)
		shield -= absorbed
		remaining -= absorbed
	health = max(0.0, health - remaining)
	health_changed.emit(health, max_health)
	if health <= 0.0:
		died.emit()

func apply_shield(amount: float, duration: float) -> void:
	shield = amount
	_shield_timer = duration

func apply_heal_over_time(amount: float, duration: float) -> void:
	var tick_count: int = max(1, int(duration))
	var per_tick := amount / float(tick_count)
	for i in tick_count:
		await get_tree().create_timer(1.0).timeout
		health = min(max_health, health + per_tick)
		health_changed.emit(health, max_health)

func apply_buff(buff_name: String, multiplier: float, duration: float) -> void:
	_buffs[buff_name] = duration

func get_damage_multiplier() -> float:
	return 1.5 if _buffs.has("damage_multiplier") else 1.0

func _tick_buffs(delta: float) -> void:
	for key in _buffs.keys():
		_buffs[key] -= delta
		if _buffs[key] <= 0.0:
			_buffs.erase(key)
