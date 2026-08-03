extends Resource
class_name Ability

## Base class for all Hexfall player abilities.
## Original mechanic design: energy-based techniques with cooldowns,
## an "essence" resource cost, and an ultimate "Sanctum" mechanic.

@export var ability_name: String = "Unnamed Technique"
@export var essence_cost: float = 10.0
@export var cooldown: float = 1.5
@export var icon: Texture2D

var _cooldown_remaining: float = 0.0

func is_ready() -> bool:
	return _cooldown_remaining <= 0.0

func tick_cooldown(delta: float) -> void:
	if _cooldown_remaining > 0.0:
		_cooldown_remaining = max(0.0, _cooldown_remaining - delta)

func start_cooldown() -> void:
	_cooldown_remaining = cooldown

func cooldown_fraction() -> float:
	## Returns 0.0 when ready, 1.0 when just used.
	if cooldown <= 0.0:
		return 0.0
	return _cooldown_remaining / cooldown

func cooldown_remaining() -> float:
	return _cooldown_remaining

## Override in subclasses. origin/direction come from the casting hand.
func execute(caster: Node3D, origin: Vector3, direction: Vector3) -> void:
	push_warning("Ability.execute() not implemented for %s" % ability_name)
