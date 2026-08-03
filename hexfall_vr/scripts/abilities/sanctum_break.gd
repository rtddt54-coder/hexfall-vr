extends Ability
class_name SanctumBreakAbility

## Original ultimate mechanic: caster opens a "Sanctum" - a bounded zone
## of warped space centered on them. While active, enemies inside take
## periodic damage and the caster gets a damage/speed buff. This is an
## original take on a "bounded domain" style ultimate - not tied to any
## existing franchise's named technique or character.

@export var radius: float = 6.0
@export var duration: float = 8.0
@export var tick_damage: float = 8.0
@export var tick_interval: float = 1.0
@export var caster_damage_multiplier: float = 1.5
@export var sanctum_scene: PackedScene

func execute(caster: Node3D, origin: Vector3, direction: Vector3) -> void:
	var tree := caster.get_tree()
	if tree == null:
		return

	var zone: Node3D
	if sanctum_scene:
		zone = sanctum_scene.instantiate()
	else:
		zone = _build_fallback_zone()

	tree.current_scene.add_child(zone)
	zone.global_position = caster.global_position

	if zone.has_method("activate"):
		zone.call("activate", caster, radius, duration, tick_damage, tick_interval)

	if caster.has_method("apply_buff"):
		caster.call("apply_buff", "damage_multiplier", caster_damage_multiplier, duration)

func _build_fallback_zone() -> Node3D:
	var zone := Area3D.new()
	zone.set_script(load("res://scripts/abilities/sanctum_zone_runtime.gd"))
	var mesh := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = 0.05
	mesh.mesh = cyl
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.6, 0.1, 0.8, 0.35)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(0.6, 0.1, 0.8)
	mesh.material_override = mat
	zone.add_child(mesh)
	var col := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = 4.0
	col.shape = shape
	zone.add_child(col)
	zone.collision_layer = 4
	zone.collision_mask = 5
	return zone
