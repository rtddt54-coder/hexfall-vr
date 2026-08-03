extends Area3D

## Runtime script attached to dynamically-created projectiles.

var _velocity: Vector3 = Vector3.ZERO
var _damage: float = 0.0
var _caster: Node = null
var _life: float = 4.0  ## seconds before auto-despawn
var _hit: bool = false

func launch(velocity: Vector3, damage: float, caster: Node) -> void:
	_velocity = velocity
	_damage = damage
	_caster = caster
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	global_position += _velocity * delta
	_life -= delta
	if _life <= 0.0:
		queue_free()

func _on_body_entered(other: Node) -> void:
	if _hit:
		return
	if other == _caster:
		return
	if other.has_method("take_damage"):
		_hit = true
		other.call("take_damage", _damage, _caster)
		_spawn_impact()
		queue_free()
	elif other.is_in_group("player"):
		pass  # don't self-hit
	else:
		# Hit world geometry
		_hit = true
		_spawn_impact()
		queue_free()

func _on_area_entered(other: Area3D) -> void:
	_on_body_entered(other)

func _spawn_impact() -> void:
	## Tiny flash at impact point using an OmniLight3D.
	var light := OmniLight3D.new()
	light.light_color = Color(0.4, 0.7, 1.0)
	light.light_energy = 6.0
	light.omni_range = 1.5
	get_tree().current_scene.add_child(light)
	light.global_position = global_position
	# Fade and remove after 0.15 s
	var tween := light.create_tween()
	tween.tween_property(light, "light_energy", 0.0, 0.15)
	tween.tween_callback(light.queue_free)
