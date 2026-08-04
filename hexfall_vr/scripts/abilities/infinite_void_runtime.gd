extends Node3D

## Runtime controller for Domain Expansion: Infinite Void.
## Expands dramatically from nothing, freezes every enemy inside,
## drains them each tick, then collapses.

var _caster: Node = null
var _radius: float = 20.0
var _duration: float = 10.0
var _tick_damage: float = 6.0
var _tick_interval: float = 0.4
var _time_left: float = 0.0
var _tick_timer: float = 0.0
var _frozen_enemies: Array = []
var _active: bool = false

# Node refs
var _dome: MeshInstance3D = null
var _area: Area3D = null
var _col_shape: SphereShape3D = null
var _void_light: OmniLight3D = null
var _rings: Array = []

func activate(caster: Node, radius: float, duration: float,
		tick_damage: float, tick_interval: float) -> void:
	_caster = caster
	_radius = radius
	_duration = duration
	_tick_damage = tick_damage
	_tick_interval = tick_interval
	_time_left = duration
	_tick_timer = tick_interval

	_dome = get_node_or_null("DomeMesh")
	_area = get_node_or_null("VoidArea")
	_void_light = get_node_or_null("VoidLight")
	_col_shape = get_node_or_null("VoidArea/VoidCol/") as SphereShape3D
	if _area:
		var col := _area.get_node_or_null("VoidCol")
		if col:
			_col_shape = col.shape as SphereShape3D

	for i in 6:
		var r := get_node_or_null("Ring%d" % i)
		if r:
			_rings.append(r)

	_expand()

func _expand() -> void:
	# Expand dome, rings, and collision sphere dramatically over 0.8s
	var expand_time := 0.8

	if _dome:
		var tween := _dome.create_tween()
		tween.tween_property(_dome, "scale",
			Vector3(_radius, _radius, _radius), expand_time) \
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	if _void_light:
		var lt := _void_light.create_tween()
		lt.tween_property(_void_light, "light_energy", 4.0, expand_time)

	for i in _rings.size():
		var ring: MeshInstance3D = _rings[i]
		var target_r := _radius * randf_range(0.35, 0.95)
		var ring_tween := ring.create_tween()
		ring_tween.tween_property(ring, "scale",
			Vector3(target_r, 1.0, target_r), expand_time * randf_range(0.7, 1.0)) \
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	if _col_shape:
		var ctween := create_tween()
		# AnimatableSphereShape doesn't tween directly; update via timer
		ctween.tween_method(_set_col_radius, 0.1, _radius, expand_time)

	# Mark active after expansion
	await get_tree().create_timer(expand_time).timeout
	_active = true
	_freeze_all_enemies()

func _set_col_radius(r: float) -> void:
	if _col_shape:
		_col_shape.radius = r

func _freeze_all_enemies() -> void:
	var wraiths := get_tree().get_nodes_in_group("wraiths")
	for w in wraiths:
		if w.global_position.distance_to(global_position) <= _radius:
			_apply_freeze(w)

func _apply_freeze(enemy: Node) -> void:
	if enemy in _frozen_enemies:
		return
	_frozen_enemies.append(enemy)
	# Freeze: disable physics process so it stops dead
	if enemy.has_method("set_physics_process"):
		enemy.set_physics_process(false)
	# Visual: add a heavy purple tint
	_tint_enemy(enemy, Color(0.5, 0.0, 0.8, 1.0))

func _unfreeze_all() -> void:
	for enemy in _frozen_enemies:
		if is_instance_valid(enemy):
			if enemy.has_method("set_physics_process"):
				enemy.set_physics_process(true)
			_tint_enemy(enemy, Color(0.15, 0.05, 0.2, 1.0))  # restore original
	_frozen_enemies.clear()

func _tint_enemy(enemy: Node, color: Color) -> void:
	for child in enemy.get_children():
		if child is MeshInstance3D:
			var mat := child.material_override
			if mat is StandardMaterial3D:
				mat.albedo_color = color
			break

func _process(delta: float) -> void:
	if not _active:
		return

	_time_left -= delta
	_tick_timer -= delta

	# Continuously freeze any newly spawned enemies that enter the dome
	if fmod(_time_left, 1.0) < delta:
		_freeze_all_enemies()

	if _tick_timer <= 0.0:
		_tick_timer = _tick_interval
		_damage_frozen_enemies()

	# Rotate rings for eerie effect
	for ring in _rings:
		if is_instance_valid(ring):
			ring.rotate_y(delta * randf_range(0.3, 0.9) * (1.0 if randi() % 2 == 0 else -1.0))

	if _time_left <= 0.0:
		_collapse()

func _damage_frozen_enemies() -> void:
	for enemy in _frozen_enemies:
		if is_instance_valid(enemy) and enemy.has_method("take_damage"):
			enemy.call("take_damage", _tick_damage, _caster)

func _collapse() -> void:
	_active = false
	_unfreeze_all()

	# Implode: shrink everything fast
	var collapse_time := 0.4
	if _dome:
		var t := _dome.create_tween()
		t.tween_property(_dome, "scale", Vector3.ZERO, collapse_time) \
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)

	if _void_light:
		var lt := _void_light.create_tween()
		lt.tween_property(_void_light, "light_energy", 0.0, collapse_time)

	for ring in _rings:
		if is_instance_valid(ring):
			var rt := ring.create_tween()
			rt.tween_property(ring, "scale", Vector3.ZERO, collapse_time * randf_range(0.5, 1.0))

	await get_tree().create_timer(collapse_time + 0.1).timeout
	queue_free()
