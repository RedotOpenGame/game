extends CharacterBody3D


@onready var hostile_seeker: Area3D = $HostileSeeker
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var health_label: Label = $CanvasLayer/Health


@onready var camera = $CameraControl/Yaw/Pitch/SpringArm3D/Camera3D
@onready var cam_yaw = $CameraControl/Yaw
@onready var cam_pitch = $CameraControl/Yaw/Pitch
@onready var camera_control: Node3D = $CameraControl
@onready var springArm = $CameraControl/Yaw/Pitch/SpringArm3D
@onready var character = $characterMesh
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const CAMERA_CONSTRAITS:Vector2 = Vector2(90, 180) #constraints for up and down camera movement(which doesn't let you look upwards)
const CAMERA_SCALE_CONSTRAINTS:Vector2 = Vector2(4, 40.0) #how far or close the camera may be
var max_health:float = 100.0
var health:float = max_health

var curr_scrap:int = 0
var max_scrap:int = 3

var interact_target:Node3D
var followers:Array = [] 
var follower_amount:int = 0
var ignore_first_input:bool = true

var nearby_hostiles:Array = []

func _ready() -> void:
	health_label.text = str("Health: ", health, "/", max_health)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_action_pressed("right_click"):
		if !ignore_first_input:
			cam_yaw.rotate_y(deg_to_rad(-event.relative.x * 0.5))
			cam_pitch.rotate_x(deg_to_rad(-event.relative.y * 0.5))
			cam_pitch.rotation.x = clamp(cam_pitch.rotation.x, deg_to_rad(-CAMERA_CONSTRAITS.x), deg_to_rad(180))
		else:
			ignore_first_input = false
	if event is InputEventMouseButton:
		if event.button_index == 4:
			springArm.spring_length = max(springArm.spring_length - 0.1, CAMERA_SCALE_CONSTRAINTS.x)
		if event.button_index == 5:
			springArm.spring_length = min(springArm.spring_length + 0.1, CAMERA_SCALE_CONSTRAINTS.y)
	
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
		var throwable = followers.front()
		if throwable:
			throwable.throw()
		#followers.pick_random().death()
		

func _process(_delta: float) -> void:
	if Input.is_action_pressed("left_click"):
		anim.play("attack")

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

func teleport_allies_with_me() -> void:
	for i in followers:
		i.global_position = global_position

func get_scrap(amount) -> void:
	curr_scrap = min(max_scrap, curr_scrap + amount)
	$CanvasLayer/Label.text = str("You are carrying: ", curr_scrap, "/", max_scrap, " scrap")

func remove_scrap() -> int:
	var old_amount:int = curr_scrap
	curr_scrap = 0
	$CanvasLayer/Label.text = str("You are carrying: ", curr_scrap, "/", max_scrap, " scrap")
	return old_amount

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

func damage_func(amount:float) -> void:
	health -= amount
	health_label.text = str("Health: ", health, "/", max_health)
	if health <= 0:
		death()

func death():
	print("You are dead. Now what?")
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/overworld.tscn")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if "damage_func" in body:
		body.damage_func(8)


func _on_hostile_seeker_body_entered(body: Node3D) -> void:
	if body.is_in_group("Hostile"):
		nearby_hostiles.append(body)


func _on_hostile_seeker_body_exited(body: Node3D) -> void:
	nearby_hostiles.erase(body)
