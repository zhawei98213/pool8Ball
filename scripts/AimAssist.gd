extends Node3D

@export var cue_ball_path: NodePath
@export var table_width := 2.54
@export var table_length := 1.27
@export var ball_radius := 0.028575
@export var aim_angle_limit_deg := 10.0

@onready var _cue_line: MeshInstance3D = $CueLine
@onready var _target_line: MeshInstance3D = $TargetLine
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
	var cue_pos: Vector3 = _cue_ball.global_transform.origin
	var aim_dir: Vector3 = direction.normalized()
	var target_ball: RigidBody3D = _find_target_ball(cue_pos, aim_dir)
	if target_ball == null:
		_set_visible(false)
		return
	_set_visible(true)
	var target_pos: Vector3 = target_ball.global_transform.origin
	var ghost_pos: Vector3 = target_pos - aim_dir * (ball_radius * 2.0)
	_set_line(_cue_line, cue_pos, ghost_pos)
	_ghost_ball.global_transform.origin = ghost_pos
	var pocket_pos: Vector3 = _find_best_pocket(target_pos, aim_dir)
	_set_line(_target_line, target_pos, pocket_pos)

func _set_visible(show_lines: bool) -> void:
	_cue_line.visible = show_lines
	_target_line.visible = show_lines
	_ghost_ball.visible = show_lines

func _find_target_ball(cue_pos: Vector3, aim_dir: Vector3) -> RigidBody3D:
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var origin := cue_pos + Vector3(0.0, ball_radius, 0.0)
	var max_dist := max(table_width, table_length) * 2.0
	var query := PhysicsRayQueryParameters3D.create(origin, origin + aim_dir * max_dist)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.collision_mask = 1
	query.exclude = [_cue_ball.get_rid()]
	var hit := space.intersect_ray(query)
	if not hit:
		return null
	if hit.collider is RigidBody3D:
		return hit.collider
	return null

func _find_best_pocket(target_pos: Vector3, aim_dir: Vector3) -> Vector3:
	var best_pocket: Vector3 = _pockets[0]
	var best_score: float = -1.0
	for pocket in _pockets:
		var to_pocket: Vector3 = (pocket - target_pos)
		to_pocket.y = 0.0
		if to_pocket.length() < 0.001:
			continue
		var dot: float = aim_dir.dot(to_pocket.normalized())
		if dot > best_score:
			best_score = dot
			best_pocket = pocket
	return best_pocket

func _build_pockets() -> void:
	var half_w: float = table_width * 0.5
	var half_l: float = table_length * 0.5
	_pockets = [
		Vector3(-half_w, 0.0, -half_l),
		Vector3(0.0, 0.0, -half_l),
		Vector3(half_w, 0.0, -half_l),
		Vector3(-half_w, 0.0, half_l),
		Vector3(0.0, 0.0, half_l),
		Vector3(half_w, 0.0, half_l),
	]

func _set_line(line: MeshInstance3D, from: Vector3, to: Vector3) -> void:
	var mesh := ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_add_vertex(from)
	mesh.surface_add_vertex(to)
	mesh.surface_end()
	line.mesh = mesh
