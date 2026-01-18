extends Node3D

@export var distance := 3.6
@export var min_distance := 1.5
@export var max_distance := 6.5
@export var yaw_speed := 0.01
@export var pitch_speed := 0.01
@export var min_pitch := deg_to_rad(-10.0)
@export var max_pitch := deg_to_rad(60.0)

var _yaw := 0.0
var _pitch := deg_to_rad(40.0)
var _orbiting := false

@onready var _camera: Camera3D = $Camera3D

func _ready() -> void:
	_update_camera_transform()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_orbiting = event.pressed
		if event.is_action_pressed("zoom_in"):
			distance = max(min_distance, distance - 0.15)
			_update_camera_transform()
		if event.is_action_pressed("zoom_out"):
			distance = min(max_distance, distance + 0.15)
			_update_camera_transform()
	elif event is InputEventMouseMotion and _orbiting:
		_yaw -= event.relative.x * yaw_speed
		_pitch -= event.relative.y * pitch_speed
		_pitch = clamp(_pitch, min_pitch, max_pitch)
		_update_camera_transform()

func _update_camera_transform() -> void:
	var basis := Basis()
	basis = basis.rotated(Vector3.UP, _yaw)
	basis = basis.rotated(Vector3.RIGHT, _pitch)
	var offset := basis * Vector3(0.0, 0.0, distance)
	_camera.global_transform.origin = global_transform.origin + offset
	_camera.look_at(global_transform.origin, Vector3.UP)

func get_camera() -> Camera3D:
	return _camera
