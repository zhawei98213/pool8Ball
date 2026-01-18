extends Node

@export var cue_ball_path: NodePath
@export var camera_rig_path: NodePath
@export var table_height := 0.0
@export var ball_radius := 0.028575
@export var max_shot_power := 12.0

var _cue_ball: RigidBody3D
var _camera_rig: Node3D
var _camera: Camera3D

var _placement_mode := false
var _selected_ball: RigidBody3D = null
var _aiming := false
var _aim_start := Vector2.ZERO

var _default_positions := {}

func _ready() -> void:
	_cue_ball = get_node(cue_ball_path)
	_camera_rig = get_node(camera_rig_path)
	_camera = _camera_rig.get_camera()
	_cache_default_positions()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("place_mode"):
		_placement_mode = !_placement_mode
		_release_selected_ball()
	if event.is_action_pressed("reset_balls"):
		_reset_balls()

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_on_left_press(event.position)
			else:
				_on_left_release(event.position)
		if event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
			_release_selected_ball()

func _physics_process(delta: float) -> void:
	if _placement_mode and _selected_ball:
		var hit_pos := _raycast_table(get_viewport().get_mouse_position())
		if hit_pos != null:
			var target: Vector3 = hit_pos
			target.y = table_height + ball_radius
			_selected_ball.global_transform.origin = target

func _on_left_press(screen_pos: Vector2) -> void:
	if _placement_mode:
		_select_ball(screen_pos)
		return
	_aiming = true
	_aim_start = screen_pos

func _on_left_release(screen_pos: Vector2) -> void:
	if _placement_mode:
		_release_selected_ball()
		return
	if not _aiming:
		return
	_aiming = false
	var hit_pos := _raycast_table(screen_pos)
	if hit_pos == null:
		return
	var direction: Vector3 = (hit_pos - _cue_ball.global_transform.origin)
	direction.y = 0.0
	if direction.length() < 0.01:
		return
	var drag_len := _aim_start.distance_to(screen_pos)
	var power := clamp(drag_len / 300.0, 0.1, 1.0) * max_shot_power
	direction = direction.normalized()
	_cue_ball.apply_impulse(direction * power)

func _select_ball(screen_pos: Vector2) -> void:
	var hit = _raycast_objects(screen_pos)
	if hit and hit.collider is RigidBody3D:
		_selected_ball = hit.collider
		_selected_ball.freeze = true

func _release_selected_ball() -> void:
	if _selected_ball:
		_selected_ball.freeze = false
		_selected_ball = null

func _raycast_table(screen_pos: Vector2) -> Variant:
	var origin := _camera.project_ray_origin(screen_pos)
	var dir := _camera.project_ray_normal(screen_pos)
	var plane := Plane(Vector3.UP, table_height)
	var hit_pos := plane.intersects_ray(origin, dir)
	return hit_pos

func _raycast_objects(screen_pos: Vector2) -> Dictionary:
	var origin := _camera.project_ray_origin(screen_pos)
	var dir := _camera.project_ray_normal(screen_pos)
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(origin, origin + dir * 10.0)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return space.intersect_ray(query)

func _cache_default_positions() -> void:
	_default_positions.clear()
	var balls := get_tree().get_nodes_in_group("balls")
	for ball in balls:
		_default_positions[ball] = ball.global_transform.origin

func _reset_balls() -> void:
	for ball in _default_positions.keys():
		ball.linear_velocity = Vector3.ZERO
		ball.angular_velocity = Vector3.ZERO
		ball.global_transform.origin = _default_positions[ball]
