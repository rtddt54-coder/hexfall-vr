extends Node3D
class_name GameManager

## Hexfall game state manager.
## Connects player and wave spawner signals, drives the HUD,
## and handles game-over / restart flow.

@export var hud_node: NodePath
@export var player_node: NodePath
@export var wave_spawner_node: NodePath

enum State { PLAYING, GAME_OVER }

var state: State = State.PLAYING

@onready var _hud: Node = get_node_or_null(hud_node)
@onready var _player: Player = get_node_or_null(player_node)
@onready var _spawner: WaveSpawner = get_node_or_null(wave_spawner_node)

func _ready() -> void:
	if _player:
		_player.health_changed.connect(_on_health_changed)
		_player.essence_changed.connect(_on_essence_changed)
		_player.shield_changed.connect(_on_shield_changed)
		_player.score_changed.connect(_on_score_changed)
		_player.died.connect(_on_player_died)

	if _spawner:
		_spawner.wave_started.connect(_on_wave_started)
		_spawner.wave_cleared.connect(_on_wave_cleared)

	# Push initial state to HUD
	if _player and _hud:
		_hud.call("update_health", _player.max_health, _player.max_health)
		_hud.call("update_essence", _player.max_essence, _player.max_essence)
		_hud.call("update_shield", 0.0)
		_hud.call("update_score", 0)
		_hud.call("update_wave", 0)

func _on_health_changed(current: float, max_val: float) -> void:
	if _hud:
		_hud.call("update_health", current, max_val)

func _on_essence_changed(current: float, max_val: float) -> void:
	if _hud:
		_hud.call("update_essence", current, max_val)

func _on_shield_changed(current: float) -> void:
	if _hud:
		_hud.call("update_shield", current)

func _on_score_changed(new_score: int) -> void:
	if _hud:
		_hud.call("update_score", new_score)

func _on_wave_started(wave_num: int, enemy_count: int) -> void:
	if _hud:
		_hud.call("update_wave", wave_num)
		_hud.call("show_wave_banner", "Wave %d — %d Wraiths" % [wave_num, enemy_count])

func _on_wave_cleared(wave_num: int) -> void:
	if _hud:
		_hud.call("show_wave_banner", "Wave %d Cleared!" % wave_num)

func _on_player_died() -> void:
	state = State.GAME_OVER
	if _spawner:
		_spawner.set_process(false)
	if _hud:
		var final_score := _player.score if _player else 0
		var final_wave := _spawner.wave_number if _spawner else 0
		_hud.call("show_game_over", final_score, final_wave)
