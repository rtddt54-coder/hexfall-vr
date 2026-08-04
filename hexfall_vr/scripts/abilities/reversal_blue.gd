extends Ability
class_name ReversalBlueAbility

## Blue Reversal — essence surge. Instantly restores a large chunk of
## essence (mana), letting you chain more abilities. Visual: blue flash.

@export var essence_restore: float = 45.0
@export var burst_color: Color = Color(0.1, 0.5, 1.0)

func execute(caster: Node3D, origin: Vector3, direction: Vector3) -> void:
	if caster.has_method("restore_essence"):
		caster.call("restore_essence", essence_restore)
	else:
		# Fallback: directly set if the method isn't present
		if "essence" in caster and "max_essence" in caster:
			caster.essence = min(caster.max_essence, caster.essence + essence_restore)
	_spawn_burst(caster.get_tree(), origin)

func _spawn_burst(tree: SceneTree, pos: Vector3) -> void:
	if tree == null:
		return
	var light := OmniLight3D.new()
	light.light_color = burst_color
	light.light_energy = 10.0
	light.omni_range = 2.0
	tree.current_scene.add_child(light)
	light.global_position = pos
	var tween := light.create_tween()
	tween.tween_property(light, "light_energy", 0.0, 0.5)
	tween.tween_callback(light.queue_free)
