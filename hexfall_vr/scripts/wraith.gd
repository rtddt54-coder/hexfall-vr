extends CharacterBody3D
class_name Wraith

## Original enemy type for Hexfall. Simple chase-and-melee AI.
## Not based on any existing franchise's specific creature designs.

@export var max_health: float = 60.0
@export var move_speed: float = 3.0
@export var attack_range: float = 1.2
@export var attack_damage: float = 10.0
@export var attack_cooldown: float = 1.2

var health: float
var _target: Node3D = null
var _attack_timer: float = 0.0

signal died(wraith: Wraith)

func _ready() -> void:
	health = max_health
	add_to_group("wraiths")
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_target = players[0]

func _physics_process(delta: float) -> void:
	if _target == null or health <= 0.0:
		return

	_attack_timer = max(0.0, _attack_timer - delta)

	var to_target: Vector3 = _target.global_position - global_position
	to_target.y = 0
	var dist := to_target.length()

	if dist > attack_range:
		var dir := to_target.normalized()
		velocity.x = dir.x * move_speed
		velocity.z = dir.z * move_speed
		look_at(Vector3(_target.global_position.x, global_position.y, _target.global_position.z), Vector3.UP)
	else:
		velocity.x = 0
		velocity.z = 0
		if _attack_timer <= 0.0:
			_attack_timer = attack_cooldown
			if _target.has_method("take_damage"):
				_target.call("take_damage", attack_damage, self)

	velocity.y -= 9.8 * delta
	move_and_slide()

func take_damage(amount: float, source: Node = null) -> void:
	var mult := 1.0
	if source and source.has_method("get_damage_multiplier"):
		mult = source.call("get_damage_multiplier")
	health -= amount * mult
	if health <= 0.0:
		died.emit(self)
		queue_free()
