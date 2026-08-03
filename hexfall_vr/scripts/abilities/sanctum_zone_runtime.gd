extends Area3D

## Runtime script for the Sanctum Break zone.
## Damages enemies inside on a tick, pulses visually.

var _caster: Node = null
var _tick_damage: float = 0.0
var _tick_interval: float = 1.0
var _time_left: float = 0.0
var _tick_timer: float = 0.0
var _mesh: MeshInstance3D = null
var _pulse_tween: Tween = null

func activate(caster: Node, radius: float, duration: float, tick_damage: float, tick_interval: float) -> void:
	_caster = caster
	_tick_damage = tick_damage
	_tick_interval = tick_interval
	_time_left = duration
	_tick_timer = tick_interval
	_mesh = _find_mesh()
	_start_pulse()

func _process(delta: float) -> void:
	if _time_left <= 0.0:
		_on_expired()
		return
	_time_left -= delta
	_tick_timer -= delta
	if _tick_timer <= 0.0:
		_tick_timer = _tick_interval
		_damage_enemies_inside()

func _damage_enemies_inside() -> void:
	for body in get_overlapping_bodies():
		if body == _caster:
			continue
		if body.has_method("take_damage"):
			body.call("take_damage", _tick_damage, _caster)

func _on_expired() -> void:
	if _pulse_tween:
		_pulse_tween.kill()
	# Fade out mesh
	if _mesh and _mesh.material_override:
		var tween := create_tween()
		tween.tween_property(_mesh.material_override, "albedo_color:a", 0.0, 0.4)
		tween.tween_callback(queue_free)
	else:
		queue_free()

func _start_pulse() -> void:
	if _mesh == null:
		return
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(_mesh, "scale", Vector3(1.05, 1.0, 1.05), 0.5)
	_pulse_tween.tween_property(_mesh, "scale", Vector3(0.98, 1.0, 0.98), 0.5)

func _find_mesh() -> MeshInstance3D:
	for child in get_children():
		if child is MeshInstance3D:
			return child
	return null
