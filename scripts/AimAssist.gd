extends Node3D

@export var cue_ball_path: NodePath
@export var table_width := 2.54
@export var table_length := 1.27
@export var ball_radius := 0.028575
@export var aim_angle_limit_deg := 10.0

@onready var _cue_line: Line3D = $CueLine
@onready var _target_line: Line3D = $TargetLine
@onready var _ghost_ball: MeshInstance3D = $GhostBall
@onready var _cue_ball: RigidBody3D = get_node(cue_ball_path)

var _pockets: Array[Vector3] = []

func _ready() -> void:
	_build_pockets()
	_set_visible(false)

func update_aim(direction: Vector3, aiming: bool) -> void:
	if not aiming:
		_set_visible(false)
		return
	if direction.length() < 0.001:
		_set_visible(false)
		return
	var cue_pos := _cue_ball.global_transform.origin
	var aim_dir := direction.normalized()
	var target_ball := _find_target_ball(cue_pos, aim_dir)
	if target_ball == null:
		_set_visible(false)
		return
	_set_visible(true)
	var target_pos := target_ball.global_transform.origin
	var ghost_pos := target_pos - aim_dir * (ball_radius * 2.0)
	_cue_line.points = PackedVector3Array([cue_pos, ghost_pos])
	_ghost_ball.global_transform.origin = ghost_pos
	var pocket_pos := _find_best_pocket(target_pos, aim_dir)
	_target_line.points = PackedVector3Array([target_pos, pocket_pos])

func _set_visible(visible: bool) -> void:
	_cue_line.visible = visible
	_target_line.visible = visible
	_ghost_ball.visible = visible

func _find_target_ball(cue_pos: Vector3, aim_dir: Vector3) -> RigidBody3D:
	var balls := get_tree().get_nodes_in_group("balls")
	var best_ball: RigidBody3D = null
	var best_score := -1.0
	var limit_cos := cos(deg_to_rad(aim_angle_limit_deg))
	for ball in balls:
		if ball == _cue_ball:
			continue
		var to_ball := (ball.global_transform.origin - cue_pos)
		to_ball.y = 0.0
		if to_ball.length() < 0.001:
			continue
		var dir := to_ball.normalized()
		var dot := aim_dir.dot(dir)
		if dot < limit_cos:
			continue
		if dot > best_score:
			best_score = dot
			best_ball = ball
	return best_ball

func _find_best_pocket(target_pos: Vector3, aim_dir: Vector3) -> Vector3:
	var best_pocket := _pockets[0]
	var best_score := -1.0
	for pocket in _pockets:
		var to_pocket := (pocket - target_pos)
		to_pocket.y = 0.0
		if to_pocket.length() < 0.001:
			continue
		var dot := aim_dir.dot(to_pocket.normalized())
		if dot > best_score:
			best_score = dot
			best_pocket = pocket
	return best_pocket

func _build_pockets() -> void:
	var half_w := table_width * 0.5
	var half_l := table_length * 0.5
	_pockets = [
		Vector3(-half_w, 0.0, -half_l),
		Vector3(0.0, 0.0, -half_l),
		Vector3(half_w, 0.0, -half_l),
		Vector3(-half_w, 0.0, half_l),
		Vector3(0.0, 0.0, half_l),
		Vector3(half_w, 0.0, half_l),
	]
