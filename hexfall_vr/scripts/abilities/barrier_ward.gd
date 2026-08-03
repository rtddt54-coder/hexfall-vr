extends Ability
class_name BarrierWardAbility

## Short-duration damage-absorbing shield around the caster.

@export var absorb_amount: float = 40.0
@export var duration: float = 3.0

func execute(caster: Node3D, origin: Vector3, direction: Vector3) -> void:
	if caster.has_method("apply_shield"):
		caster.call("apply_shield", absorb_amount, duration)
