extends Ability
class_name ReversalPurpleAbility

## Purple Reversal — sanctum echo. A short-range area pulse that heals
## the caster and briefly slows nearby enemies. Visual: purple ring.

@export var heal_amount: float = 35.0
@export var slow_radius: float = 4.0
@export var slow_multiplier: float = 0.4
@export var slow_duration: float = 2.0
@export var burst_color: Color = Color(0.7, 0.1, 1.0)

func execute(caster: Node3D, origin: Vector3, direction: Vector3) -> void:
	# Heal the caster
	if caster.has_method("apply_heal_over_time"):
		caster.call("apply_heal_over_time", heal_amount, 1.5)

	# Slow nearby wraiths
	var tree := caster.get_tree()
	if tree:
		var wraiths := tree.get_nodes_in_group("wraiths")
		for w in wraiths:
			if w.global_position.distance_to(caster.global_position) <= slow_radius:
				if w.has_method("apply_slow"):
					w.call("apply_slow", slow_multiplier, slow_duration)

	_spawn_ring(tree, origin)

func _spawn_ring(tree: SceneTree, pos: Vector3) -> void:
	if tree == null:
		return
	var light := OmniLight3D.new()
	light.light_color = burst_color
	light.light_energy = 12.0
	light.omni_range = slow_radius
	tree.current_scene.add_child(light)
	light.global_position = pos
	var tween := light.create_tween()
	tween.tween_property(light, "omni_range", slow_radius * 2.0, 0.3)
	tween.parallel().tween_property(light, "light_energy", 0.0, 0.4)
	tween.tween_callback(light.queue_free)
