extends Ability
class_name EnergyBoltAbility

## Ranged essence projectile. Fast travel time, moderate damage.

@export var damage: float = 18.0
@export var speed: float = 30.0
@export var projectile_scene: PackedScene

func execute(caster: Node3D, origin: Vector3, direction: Vector3) -> void:
	var tree := caster.get_tree()
	if tree == null:
		return

	var proj: Node3D
	if projectile_scene:
		proj = projectile_scene.instantiate()
	else:
		# Fallback primitive projectile if no scene assigned yet.
		proj = _build_fallback_projectile()

	tree.current_scene.add_child(proj)
	proj.global_position = origin

	if proj.has_method("launch"):
		proj.call("launch", direction.normalized() * speed, damage, caster)

func _build_fallback_projectile() -> Node3D:
	var body := Area3D.new()
	body.set_script(load("res://scripts/abilities/projectile_runtime.gd"))
	var mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.08
	sphere.height = 0.16
	mesh.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.emission_enabled = true
	mat.emission = Color(0.3, 0.7, 1.0)
	mat.albedo_color = Color(0.3, 0.7, 1.0)
	mesh.material_override = mat
	body.add_child(mesh)
	var col := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.08
	col.shape = shape
	body.add_child(col)
	body.collision_layer = 4
	body.collision_mask = 5 # World + Enemies
	return body
