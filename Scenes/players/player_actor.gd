extends CharacterBody3D

@onready var camera = $CameraControl/Camera3D
@onready var camera_control: Node3D = $CameraControl
@onready var character = $characterMesh
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const CAMERA_CONSTRAITS:Vector2 = Vector2(90, 180)
const CAMERA_SCALE_CONSTRAINTS:Vector2 = Vector2(4, 40.0)

var interact_target:Node3D
var followers:Array = [] #meant to get who is following me so we could be in a snake-like f0rmation.
var follower_amount:int = 0
var ignore_first_input:bool = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_action_pressed("right_click"):
		if !ignore_first_input:
			camera_control.rotation.x -= deg_to_rad(event.velocity.y / 350)
			if camera_control.rotation.x > deg_to_rad(CAMERA_CONSTRAITS.x):
				camera_control.rotation.x = deg_to_rad(CAMERA_CONSTRAITS.x)
			elif camera_control.rotation.x < 0:
				camera_control.rotation.x = 0
			camera_control.rotation.y -= deg_to_rad(event.velocity.x / 350)
		else:
			ignore_first_input = false
	if event is InputEventMouseButton:
		if event.button_index == 4:
			camera.position.y = max(camera.position.y - 1, CAMERA_SCALE_CONSTRAINTS.x)
		if event.button_index == 5:
			camera.position.y = min(camera.position.y + 1, CAMERA_SCALE_CONSTRAINTS.y)
	
	if Input.is_action_just_released("right_click"):
		ignore_first_input = true
	if Input.is_action_just_pressed("["):
		camera_control.rotation.y -= deg_to_rad(45)
	if Input.is_action_just_pressed("]"):
		camera_control.rotation.y += deg_to_rad(45)
	if Input.is_action_just_pressed("backslash"):
		camera_control.rotation.x = deg_to_rad(40)
		camera_control.rotation.y = 0
		camera.position.y = 8
	
	if Input.is_action_just_pressed("f"):
		followers.pick_random().death()
		
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var target_plane_mouse = Plane(Vector3(0, 1, 0), position.y)
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var cursor_pos_on_plane = target_plane_mouse.intersects_ray(from, to)
	if cursor_pos_on_plane:
		character.look_at(cursor_pos_on_plane)
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("a", "d", "w", "s").rotated(-camera_control.rotation.y)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	if Input.is_action_just_pressed("e") and is_instance_valid(interact_target):
		interact_target.interaction()


func signal_follow(body):
	followers.append(body)
	body.unit_index = follower_amount
	follower_amount += 1

func ally_died(body) -> void:
	follower_amount -= 1
	followers.erase(body)
	var incrementer:int = 0
	for i in followers:
		i.unit_index = incrementer
		incrementer += 1
