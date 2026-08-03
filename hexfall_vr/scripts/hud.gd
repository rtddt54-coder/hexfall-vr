extends Node3D
class_name HexfallHUD

## World-space VR HUD — floats in front of the XRCamera.
## Updated by GameManager via its signal callbacks.

@export var follow_camera: NodePath
@export var hud_distance: float = 0.65
@export var hud_offset: Vector3 = Vector3(0.0, -0.18, 0.0)

## Panel references — set up in HUD.tscn
@onready var _health_bar: SubViewport  = null  # filled at runtime via _build_hud
@onready var _camera: XRCamera3D      = null

var _max_health: float  = 100.0
var _max_essence: float = 100.0
var _max_shield: float  = 80.0
var _score: int = 0
var _wave: int  = 0

# Runtime label / progress references (created procedurally)
var _health_value: float  = 100.0
var _essence_value: float = 100.0
var _shield_value: float  = 0.0
var _wave_banner_timer: float = 0.0
var _wave_banner_text: String = ""
var _game_over: bool = false

# Drawn each frame via _draw on a SubViewport MeshInstance
var _viewport: SubViewport
var _mesh_inst: MeshInstance3D

const HUD_W  := 512
const HUD_H  := 128
const GAME_OVER_H := 256

func _ready() -> void:
	if follow_camera != &"":
		_camera = get_node_or_null(follow_camera)
	_build_mesh_hud()

func _process(delta: float) -> void:
	_follow_camera(delta)
	if _wave_banner_timer > 0.0:
		_wave_banner_timer -= delta
	_render_hud()

func _follow_camera(delta: float) -> void:
	if _camera == null:
		return
	var target_pos := _camera.global_position \
		+ (-_camera.global_transform.basis.z * hud_distance) \
		+ _camera.global_transform.basis.y * hud_offset.y
	global_position = global_position.lerp(target_pos, 10.0 * delta)
	global_rotation.y = lerp_angle(global_rotation.y, _camera.global_rotation.y, 10.0 * delta)

# ── Public API called by GameManager ──────────────────────────────────────

func update_health(current: float, max_val: float) -> void:
	_health_value = current
	_max_health   = max_val

func update_essence(current: float, max_val: float) -> void:
	_essence_value = current
	_max_essence   = max_val

func update_shield(current: float) -> void:
	_shield_value = current

func update_score(new_score: int) -> void:
	_score = new_score

func update_wave(wave_num: int) -> void:
	_wave = wave_num

func show_wave_banner(text: String) -> void:
	_wave_banner_text  = text
	_wave_banner_timer = 2.8

func show_game_over(final_score: int, final_wave: int) -> void:
	_game_over   = true
	_score       = final_score
	_wave        = final_wave
	_wave_banner_text = "DEFEATED\nScore: %d | Wave %d" % [final_score, final_wave]
	_wave_banner_timer = 9999.0

# ── SubViewport canvas HUD ────────────────────────────────────────────────

func _build_mesh_hud() -> void:
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(HUD_W, HUD_H)
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_viewport.transparent_bg = true
	add_child(_viewport)

	_mesh_inst = MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(0.45, 0.11)
	_mesh_inst.mesh = quad
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = _viewport.get_texture()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_DISABLED
	_mesh_inst.material_override = mat
	add_child(_mesh_inst)

	# CanvasLayer inside the viewport
	var canvas := CanvasLayer.new()
	_viewport.add_child(canvas)

	# We'll draw by updating a ColorRect + Labels each frame via a Control
	var ctrl := _HUDControl.new()
	ctrl.hud_ref = self
	ctrl.custom_minimum_size = Vector2(HUD_W, HUD_H)
	canvas.add_child(ctrl)

## Inner class: Control node that redraws the HUD each frame.
class _HUDControl extends Control:
	var hud_ref: Node  # reference back to HexfallHUD

	func _draw() -> void:
		if hud_ref == null:
			return
		var h  := hud_ref._health_value  / max(hud_ref._max_health,  1.0)
		var e  := hud_ref._essence_value / max(hud_ref._max_essence, 1.0)
		var sh := min(hud_ref._shield_value / 80.0, 1.0)

		var bg := Color(0.05, 0.05, 0.1, 0.75)
		draw_rect(Rect2(0, 0, 512, 128), bg)

		# Health bar (red → green based on value)
		var hcol := Color(1.0 - h, h * 0.9, 0.1)
		_draw_bar(self, Rect2(16, 10, 220, 22), h, Color(0.3, 0.0, 0.0), hcol, "HP")

		# Essence bar (blue)
		_draw_bar(self, Rect2(16, 44, 220, 22), e, Color(0.0, 0.0, 0.35), Color(0.2, 0.5, 1.0), "EN")

		# Shield bar (cyan) — only when active
		if hud_ref._shield_value > 0.0:
			_draw_bar(self, Rect2(16, 78, 220, 18), sh, Color(0.0, 0.2, 0.2), Color(0.2, 0.9, 0.9), "SH")

		# Score & Wave
		draw_string(ThemeDB.fallback_font, Vector2(260, 28), "Score: %d" % hud_ref._score,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
		draw_string(ThemeDB.fallback_font, Vector2(260, 60), "Wave: %d" % hud_ref._wave,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.8, 0.7, 1.0))

		# Wave banner
		if hud_ref._wave_banner_timer > 0.0:
			var alpha := clampf(hud_ref._wave_banner_timer, 0.0, 1.0)
			draw_string(ThemeDB.fallback_font, Vector2(256, 104),
				hud_ref._wave_banner_text,
				HORIZONTAL_ALIGNMENT_CENTER, 512, 18,
				Color(1.0, 0.9, 0.3, alpha))

	func _process(_d: float) -> void:
		queue_redraw()

	static func _draw_bar(ctrl: Control, rect: Rect2, fraction: float,
			bg_col: Color, fill_col: Color, label: String) -> void:
		ctrl.draw_rect(rect, bg_col)
		var filled := Rect2(rect.position, Vector2(rect.size.x * clampf(fraction, 0.0, 1.0), rect.size.y))
		ctrl.draw_rect(filled, fill_col)
		ctrl.draw_rect(rect, Color(1, 1, 1, 0.25), false, 1.0)
		ctrl.draw_string(ThemeDB.fallback_font,
			rect.position + Vector2(4, rect.size.y - 4),
			label, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)

func _render_hud() -> void:
	pass  # Rendering is driven by the _HUDControl._process → queue_redraw loop
