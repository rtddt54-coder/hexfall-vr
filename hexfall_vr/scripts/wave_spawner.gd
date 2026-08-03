extends Node3D
class_name WaveSpawner

@export var wraith_scene: PackedScene
@export var spawn_points: Array[NodePath] = []
@export var base_wave_size: int = 3
@export var wave_size_increase: int = 1  ## extra per wave
@export var time_between_waves: float = 6.0
@export var initial_delay: float = 2.0

var wave_number: int = 0
var _wave_timer: float = 0.0
var _alive_count: int = 0
var _started: bool = false

signal wave_started(wave_num: int, enemy_count: int)
signal wave_cleared(wave_num: int)
signal all_waves_cleared

func _ready() -> void:
	_wave_timer = initial_delay

func _process(delta: float) -> void:
	if _alive_count > 0:
		return
	if wave_number > 0:
		wave_cleared.emit(wave_number)

	_wave_timer -= delta
	if _wave_timer <= 0.0:
		wave_number += 1
		_spawn_wave()
		_wave_timer = time_between_waves

func _spawn_wave() -> void:
	if wraith_scene == null or spawn_points.is_empty():
		return
	var count := base_wave_size + (wave_number - 1) * wave_size_increase
	wave_started.emit(wave_number, count)

	for i in count:
		var point_path := spawn_points[i % spawn_points.size()]
		var point := get_node_or_null(point_path) as Node3D
		if point == null:
			continue
		var w: Node3D = wraith_scene.instantiate()
		get_tree().current_scene.add_child(w)
		# Small random jitter around spawn point so wraiths don't overlap
		var jitter := Vector3(randf_range(-0.8, 0.8), 0.0, randf_range(-0.8, 0.8))
		w.global_position = point.global_position + jitter
		if w.has_method("scale_for_wave"):
			w.call("scale_for_wave", wave_number)
		if w.has_signal("died"):
			w.died.connect(_on_wraith_died)
		_alive_count += 1

func _on_wraith_died(_w: Node) -> void:
	_alive_count = max(0, _alive_count - 1)
