extends Node3D
class_name WaveSpawner

@export var wraith_scene: PackedScene
@export var spawn_points: Array[NodePath] = []
@export var wave_size: int = 4
@export var time_between_waves: float = 6.0

var _wave_timer: float = 2.0
var _alive_count: int = 0

func _process(delta: float) -> void:
	if _alive_count > 0:
		return
	_wave_timer -= delta
	if _wave_timer <= 0.0:
		_spawn_wave()
		_wave_timer = time_between_waves

func _spawn_wave() -> void:
	if wraith_scene == null or spawn_points.is_empty():
		return
	for i in wave_size:
		var point := get_node(spawn_points[i % spawn_points.size()]) as Node3D
		if point == null:
			continue
		var w := wraith_scene.instantiate()
		get_tree().current_scene.add_child(w)
		w.global_position = point.global_position
		if w.has_signal("died"):
			w.died.connect(_on_wraith_died)
		_alive_count += 1

func _on_wraith_died(_w: Node) -> void:
	_alive_count = max(0, _alive_count - 1)
