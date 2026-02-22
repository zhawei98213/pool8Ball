extends Node3D

@export var cue_ball_path: NodePath
@export var offset := Vector3(-1.6, 0.22, 0.0)
@export var look_ahead := Vector3(0.7, 0.04, 0.0)
@export var smoothing := 0.08

@onready var _cue_ball: RigidBody3D = get_node(cue_ball_path)
@onready var _camera: Camera3D = $Camera3D

func _physics_process(_delta: float) -> void:
	if not _cue_ball:
		return
	var target_pos := _cue_ball.global_transform.origin + offset
	_camera.global_transform.origin = _camera.global_transform.origin.lerp(target_pos, smoothing)
	var look_target := _cue_ball.global_transform.origin + look_ahead
	_camera.look_at(look_target, Vector3.UP)

func get_camera() -> Camera3D:
	return _camera

func is_top_down() -> bool:
	return false
