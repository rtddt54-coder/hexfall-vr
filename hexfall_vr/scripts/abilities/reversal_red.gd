extends Ability
class_name ReversalRedAbility

## Red Reversal — aggression surge. Grants a temporary damage multiplier
## and speed buff. Visual: red burst on the casting hand.

@export var damage_multiplier: float = 2.0
@export var speed_multiplier: float = 1.4
@export var duration: float = 4.0
@export var burst_color: Color = Color(1.0, 0.15, 0.1)

func execute(caster: Node3D, origin: Vector3, direction: Vector3) -> void:
	if caster.has_method("apply_buff"):
		caster.call("apply_buff", "damage_multiplier", damage_multiplier, duration)
		caster.call("apply_buff", "speed_multiplier", speed_multiplier, duration)
	_spawn_burst(caster.get_tree(), origin)

func _spawn_burst(tree: SceneTree, pos: Vector3) -> void:
	if tree == null:
		return
	var light := OmniLight3D.new()
	light.light_color = burst_color
	light.light_energy = 8.0
	light.omni_range = 2.5
	tree.current_scene.add_child(light)
	light.global_position = pos
	var tween := light.create_tween()
	tween.tween_property(light, "light_energy", 0.0, duration * 0.3)
	tween.tween_callback(light.queue_free)
