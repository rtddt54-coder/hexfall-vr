extends Area3D

var _caster: Node = null
var _tick_damage: float = 0.0
var _tick_interval: float = 1.0
var _time_left: float = 0.0
var _tick_timer: float = 0.0

func activate(caster: Node, radius: float, duration: float, tick_damage: float, tick_interval: float) -> void:
	_caster = caster
	_tick_damage = tick_damage
	_tick_interval = tick_interval
	_time_left = duration
	_tick_timer = tick_interval

func _physics_process(delta: float) -> void:
	if _time_left <= 0.0:
		queue_free()
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
