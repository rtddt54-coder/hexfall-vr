extends Area3D

var _velocity: Vector3 = Vector3.ZERO
var _damage: float = 0.0
var _caster: Node = null
var _life: float = 3.0

func launch(velocity: Vector3, damage: float, caster: Node) -> void:
	_velocity = velocity
	_damage = damage
	_caster = caster
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	global_position += _velocity * delta
	_life -= delta
	if _life <= 0.0:
		queue_free()

func _on_body_entered(other: Node) -> void:
	if other == _caster:
		return
	if other.has_method("take_damage"):
		other.call("take_damage", _damage, _caster)
	queue_free()
