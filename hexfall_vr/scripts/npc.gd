extends CharacterBody3D
class_name PassiveNPC

## Passive NPC — stands in the arena and does nothing hostile.
## Slowly rotates toward the nearest sound/activity, occasionally
## looks around. No AI aggression, no combat involvement.

@export var wander_speed: float = 0.4
@export var wander_radius: float = 3.0
@export var idle_time_min: float = 3.0
@export var idle_time_max: float = 7.0
@export var npc_color: Color = Color(0.2, 0.55, 0.3)  ## Greenish to distinguish from enemies

var _home_position: Vector3
var _target_position: Vector3
var _idle_timer: float = 0.0
var _is_wandering: bool = false

func _ready() -> void:
	_home_position = global_position
	_target_position = global_position
	_idle_timer = randf_range(idle_time_min, idle_time_max)
	add_to_group("npcs")
	_set_npc_color()

func _physics_process(delta: float) -> void:
	_idle_timer -= delta

	if _is_wandering:
		var to_target := _target_position - global_position
		to_target.y = 0.0
		var dist := to_target.length()
		if dist < 0.25:
			_is_wandering = false
			_idle_timer = randf_range(idle_time_min, idle_time_max)
			velocity = Vector3.ZERO
		else:
			var dir := to_target.normalized()
			velocity.x = dir.x * wander_speed
			velocity.z = dir.z * wander_speed
			look_at(Vector3(_target_position.x, global_position.y, _target_position.z), Vector3.UP)
	else:
		velocity.x = move_toward(velocity.x, 0.0, wander_speed)
		velocity.z = move_toward(velocity.z, 0.0, wander_speed)

		if _idle_timer <= 0.0:
			# Pick a new wander target within radius of home
			var angle := randf() * TAU
			var dist := randf_range(0.5, wander_radius)
			_target_position = _home_position + Vector3(cos(angle) * dist, 0.0, sin(angle) * dist)
			_is_wandering = true

	# Gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0.0

	move_and_slide()

func take_damage(_amount: float, _source: Node = null) -> void:
	## NPCs are invulnerable — they step back slightly when hit but stay.
	velocity += -global_transform.basis.z * 1.5

func _set_npc_color() -> void:
	var mesh := _find_mesh()
	if mesh == null:
		return
	var mat := StandardMaterial3D.new()
	mat.albedo_color = npc_color
	mat.emission_enabled = true
	mat.emission = npc_color * 0.3
	mesh.material_override = mat

func _find_mesh() -> MeshInstance3D:
	for child in get_children():
		if child is MeshInstance3D:
			return child
	return null
