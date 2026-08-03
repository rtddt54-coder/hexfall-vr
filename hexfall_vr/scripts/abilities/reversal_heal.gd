extends Ability
class_name ReversalHealAbility

## Restores health over a short window, styled as "reversing" damage.

@export var heal_amount: float = 25.0
@export var tick_duration: float = 1.5

func execute(caster: Node3D, origin: Vector3, direction: Vector3) -> void:
	if caster.has_method("apply_heal_over_time"):
		caster.call("apply_heal_over_time", heal_amount, tick_duration)
