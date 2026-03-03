extends TextureRect

@export_range(0.05, 5.0, 0.05) var pulse_speed: float = 0.6  # lower = slower
@export_range(1.0, 10.0, 0.1) var glow_min: float = 2.0
@export_range(1.0, 10.0, 0.1) var glow_max: float = 4.0
@export_range(0.5, 5.0, 0.1) var ease_power: float = 2.0   # higher = smoother/softer ends

@export var active := false

var _t: float = 0.0
@onready var _mat: ShaderMaterial = material as ShaderMaterial

func _ready() -> void:
	if _mat == null:
		push_error("No ShaderMaterial found on this node. Assign a ShaderMaterial to 'material'.")
		set_process(false)
		return
	_apply_off_state()
	if glow_max < glow_min:
		var tmp := glow_min
		glow_min = glow_max
		glow_max = tmp

func _process(delta: float) -> void:
	if not active:
		return
	_t += delta * pulse_speed
	var pulse := (sin(_t) + 1.0) * 0.5
	pulse = ease(pulse, ease_power)
	var strength = lerp(glow_min, glow_max, pulse)
	_mat.set_shader_parameter("glow_strength", strength)

func set_notifications_enabled(enabled: bool) -> void:
	if active == enabled:
		return
	active = enabled
	if not enabled:
		_apply_off_state()
	else:
		_t = 0.0
		show()

func _apply_off_state() -> void:
	_t = 0.0
	_mat.set_shader_parameter("glow_strength", 1.0)
	hide()
