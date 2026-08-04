extends Ability
class_name BarrierWardAbility

## Short-duration damage-absorbing shield around the caster.

@export var absorb_amount: float = 40.0
@export var duration: float = 3.0
@export var ward_color: Color = Color(0.2, 0.6, 1.0)

func execute(caster: Node3D, origin: Vector3, direction: Vector3) -> void:
	if caster.has_method("apply_shield"):
		caster.call("apply_shield", absorb_amount, duration)
	_spawn_flash(caster.get_tree(), origin)

func _spawn_flash(tree: SceneTree, pos: Vector3) -> void:
	if tree == null:
		return
	var light := OmniLight3D.new()
	light.light_color = ward_color
	light.light_energy = 6.0
	light.omni_range = 1.8
	tree.current_scene.add_child(light)
	light.global_position = pos
	var tween := light.create_tween()
	tween.tween_property(light, "light_energy", 0.0, duration * 0.25)
	tween.tween_callback(light.queue_free)
