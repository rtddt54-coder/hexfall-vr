extends Node3D
class_name FreeplayManager

## Freeplay mode — no waves, no enemies.
## NPCs wander the arena. The player can explore, cast abilities,
## and experiment without pressure.
## Switch to Combat mode via a menu or by pressing both grip buttons.

@export var hud_node: NodePath
@export var player_node: NodePath
@export var npc_scene: PackedScene
@export var npc_count: int = 8
@export var npc_spawn_radius: float = 10.0

@onready var _hud: Node = get_node_or_null(hud_node)
@onready var _player: Player = get_node_or_null(player_node)

var _mode_label_timer: float = 0.0

func _ready() -> void:
	if _player:
		_player.health_changed.connect(_on_health_changed)
		_player.essence_changed.connect(_on_essence_changed)
		_player.shield_changed.connect(_on_shield_changed)
		if _hud:
			_hud.call("update_health", _player.max_health, _player.max_health)
			_hud.call("update_essence", _player.max_essence, _player.max_essence)
			_hud.call("update_shield", 0.0)
			_hud.call("update_wave", 0)
			_hud.call("update_score", 0)
			_hud.call("show_wave_banner", "Freeplay — No enemies")

	_spawn_npcs()

func _spawn_npcs() -> void:
	if npc_scene == null:
		return
	for i in npc_count:
		var npc: Node3D = npc_scene.instantiate()
		get_tree().current_scene.add_child(npc)
		var angle := (float(i) / float(npc_count)) * TAU + randf_range(-0.3, 0.3)
		var dist := randf_range(2.5, npc_spawn_radius)
		npc.global_position = Vector3(cos(angle) * dist, 0.1, sin(angle) * dist)
		# Give each NPC a slightly different color
		if npc.has_method("_set_npc_color"):
			var h := float(i) / float(npc_count)
			npc.call("_set_npc_color", Color.from_hsv(h, 0.5, 0.7))

func _on_health_changed(current: float, max_val: float) -> void:
	if _hud:
		_hud.call("update_health", current, max_val)

func _on_essence_changed(current: float, max_val: float) -> void:
	if _hud:
		_hud.call("update_essence", current, max_val)

func _on_shield_changed(current: float) -> void:
	if _hud:
		_hud.call("update_shield", current)
