extends Ability
class_name InfiniteVoidAbility

## Domain Expansion: Infinite Void
## The caster opens a bounded domain that engulfs the entire arena.
## Every enemy inside is overwhelmed with infinite stimuli — frozen,
## unable to act, taking continuous damage for the duration.
## The world plunges into darkness; only the void remains.

@export var radius: float = 20.0           ## Covers the whole arena
@export var duration: float = 10.0
@export var tick_damage: float = 6.0
@export var tick_interval: float = 0.4     ## Fast ticks — relentless
@export var void_scene: PackedScene        ## Optional custom scene

func execute(caster: Node3D, origin: Vector3, direction: Vector3) -> void:
	var tree := caster.get_tree()
	if tree == null:
		return

	var domain: Node3D
	if void_scene:
		domain = void_scene.instantiate()
	else:
		domain = _build_void_domain()

	tree.current_scene.add_child(domain)
	domain.global_position = caster.global_position

	if domain.has_method("activate"):
		domain.call("activate", caster, radius, duration, tick_damage, tick_interval)

func _build_void_domain() -> Node3D:
	var root := Node3D.new()
	root.set_script(load("res://scripts/abilities/infinite_void_runtime.gd"))

	# ── Void sphere: massive dark translucent dome ──────────────────────
	var dome := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.1   # starts tiny, runtime tweens it to full radius
	sphere.height = 0.2
	sphere.is_hemisphere = false
	sphere.radial_segments = 16
	sphere.rings = 8
	dome.mesh = sphere
	dome.name = "DomeSphere"

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.0, 0.0, 0.03, 0.55)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(0.05, 0.0, 0.15)
	mat.emission_energy_multiplier = 2.0
	mat.cull_mode = BaseMaterial3D.CULL_FRONT  # render inside face
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dome.material_override = mat
	dome.name = "DomeMesh"
	root.add_child(dome)

	# ── Grid lines: two crossing floor rings ────────────────────────────
	for i in 6:
		var ring := MeshInstance3D.new()
		var torus := TorusMesh.new()
		torus.inner_radius = 0.0
		torus.outer_radius = 0.05
		torus.rings = 24
		torus.ring_segments = 8
		ring.mesh = torus
		var rmat := StandardMaterial3D.new()
		rmat.albedo_color = Color(0.5, 0.0, 0.9, 0.7)
		rmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		rmat.emission_enabled = true
		rmat.emission = Color(0.7, 0.1, 1.0)
		rmat.emission_energy_multiplier = 3.0
		rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ring.material_override = rmat
		ring.position = Vector3(0, -0.5 + i * 0.25, 0)
		ring.scale = Vector3(0.1, 1.0, 0.1)  # tweened out by runtime
		ring.name = "Ring%d" % i
		root.add_child(ring)

	# ── Central void light: deep purple point light ─────────────────────
	var void_light := OmniLight3D.new()
	void_light.light_color = Color(0.4, 0.0, 0.8)
	void_light.light_energy = 0.0   # faded in by runtime
	void_light.omni_range = 25.0
	void_light.name = "VoidLight"
	root.add_child(void_light)

	# ── Collision zone: catches all enemies ─────────────────────────────
	var area := Area3D.new()
	area.collision_layer = 4
	area.collision_mask = 8  # Enemies layer
	area.name = "VoidArea"
	var col := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.1   # tweened to full radius
	col.shape = shape
	col.name = "VoidCol"
	area.add_child(col)
	root.add_child(area)

	return root
