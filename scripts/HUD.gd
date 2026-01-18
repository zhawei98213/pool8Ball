extends CanvasLayer

@export var camera_rig_path: NodePath
@export var aim_assist_path: NodePath

@onready var _label: Label = $HelpLabel
@onready var _camera_rig: Node3D = get_node(camera_rig_path)
@onready var _aim_assist: Node = get_node(aim_assist_path)

var _visible := true

func _ready() -> void:
	_update_text()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_help"):
		_visible = !_visible
		_label.visible = _visible
		if _visible:
			_update_text()

func _process(_delta: float) -> void:
	if _visible:
		_update_text()

func _update_text() -> void:
	var view_label := "Top"
	if _camera_rig.has_method("is_top_down") and not _camera_rig.is_top_down():
		view_label = "Low"
	var assist_label := "On"
	if _aim_assist.has_method("is_enabled") and not _aim_assist.is_enabled():
		assist_label = "Off"
	_label.text = "View: %s | Assist: %s | V toggle view | G toggle assist | RMB rotate | Wheel zoom" % [view_label, assist_label]
