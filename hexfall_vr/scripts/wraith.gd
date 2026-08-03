extends CharacterBody3D
class_name Wraith

## Original enemy type for Hexfall. Chase-and-melee AI with stagger,
## flank offset, and hit-flash feedback.

@export var max_health: float = 60.0
@export var move_speed: float = 3.0
@export var attack_range: float = 1.2
@export var attack_damage: float = 10.0
@export var attack_cooldown: float = 1.2
@export var score_value: int = 100

var health: float
var _target: Node3D = null
var _attack_timer: float = 0.0
var _stagger_timer: float = 0.0
var _flank_offset: float = 0.0
var _mesh_instance: MeshInstance3D = null
var _original_emission: Color = Color(0.5, 0.1, 0.6)

signal died(wraith: Wraith)

func _ready() -> void:
	health = max_health
	add_to_group("wraiths")
	_flank_offset = randf_range(-0.6, 0.6)  # slight lateral variance per wraith
	_mesh_instance = _find_mesh()

	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_target = players[0]

func _physics_process(delta: float) -> void:
	if _target == null or health <= 0.0:
		return

	_attack_timer = max(0.0, _attack_timer - delta)

	if _stagger_timer > 0.0:
		_stagger_timer -= delta
		velocity.y -= 9.8 * delta
		move_and_slide()
		return

	var to_target: Vector3 = _target.global_position - global_position
	to_target.y = 0.0
	var dist := to_target.length()
	var dir := to_target.normalized() if dist > 0.01 else Vector3.FORWARD

	# Flank offset: strafe slightly to the side while approaching
	var strafe := dir.cross(Vector3.UP) * _flank_offset
	var effective_dir := (dir + strafe * 0.3).normalized()

	if dist > attack_range:
		velocity.x = effective_dir.x * move_speed
		velocity.z = effective_dir.z * move_speed
		look_at(Vector3(_target.global_position.x, global_position.y, _target.global_position.z), Vector3.UP)
	else:
		velocity.x = 0.0
		velocity.z = 0.0
		if _attack_timer <= 0.0:
			_attack_timer = attack_cooldown
			if _target.has_method("take_damage"):
				_target.call("take_damage", attack_damage, self)

	velocity.y -= 9.8 * delta
	move_and_slide()

func take_damage(amount: float, source: Node = null) -> void:
	if health <= 0.0:
		return
	var mult := 1.0
	if source and source.has_method("get_damage_multiplier"):
		mult = source.call("get_damage_multiplier")
	health -= amount * mult

	# Brief stagger on hit
	_stagger_timer = 0.15
	velocity = Vector3.ZERO
	_flash_hit()

	if health <= 0.0:
		# Award score to the player source
		if source and source.has_method("add_score"):
			source.call("add_score", score_value)
		died.emit(self)
		queue_free()

func scale_for_wave(wave_number: int) -> void:
	## Called by WaveSpawner to ramp up difficulty per wave.
	var multiplier := 1.0 + (wave_number - 1) * 0.15
	max_health *= multiplier
	health = max_health
	move_speed = min(5.5, move_speed * (1.0 + (wave_number - 1) * 0.05))
	attack_damage *= multiplier
	score_value = int(score_value * multiplier)

func _flash_hit() -> void:
	if _mesh_instance == null:
		return
	var mat := _mesh_instance.get_surface_override_material(0) as StandardMaterial3D
	if mat == null:
		mat = _mesh_instance.material_override as StandardMaterial3D
	if mat == null:
		return
	# Flash white, then restore
	mat.emission = Color.WHITE
	await get_tree().create_timer(0.1).timeout
	if is_inside_tree():
		mat.emission = _original_emission

func _find_mesh() -> MeshInstance3D:
	for child in get_children():
		if child is MeshInstance3D:
			return child
	return null
