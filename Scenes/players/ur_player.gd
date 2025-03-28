extends CharacterBody3D
##UR, as in, Unholy Retribution
@onready var camera_3d: Camera3D = $Camera3D
@onready var health_label: Label = $HealthLabel
@onready var gun_barrel: Marker3D = $GunBarrel
@onready var firerate: Timer = $Firerate

var bullet_scene = preload("res://Scenes/entities/Projectiles/Player/bullet.tscn")

@export var SPEED = 6.5
@export_range(0, 2) var max_acceleration:float = 1
var curr_acceleration = 0
const JUMP_VELOCITY = 4.5
const CAMERA_CONSTRAITS:Vector2 = Vector2(90, 180) #constraints for up and down camera movement(which doesn't let you look upwards)
const CAMERA_SCALE_CONSTRAINTS:Vector2 = Vector2(4, 40.0) #how far or close the camera may be
var max_health:float = 100.0
var health:float = max_health
var can_be_hit:bool = true

var curr_scrap:int = 0
var max_scrap:int = 3

var interact_target:Node3D
var curr_target:Node3D #the enemy target
var lock_on_mode:bool = false

var ignore_first_input:bool = true

var nearby_hostiles:Array = []

var can_fire:bool = true

func _ready() -> void:
	health_label.text = str("Health: ", health, "/", max_health)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
			#camera_3d.rotate_y(deg_to_rad(-event.relative.x * 0.5))
			self.rotate_y(deg_to_rad(-event.relative.x * 0.3))
			#self.rotation.y = clamp(self.rotation.y, deg_to_rad(-CAMERA_CONSTRAITS.x), deg_to_rad(180))
	if Input.is_action_just_pressed("left_control"):
		if Input.mouse_mode == 2:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif Input.mouse_mode == 0:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	#if event is InputEventMouseButton:
		#if event.button_index == 4:
			#camera_3d.spring_length = max(springArm.spring_length - 0.2, CAMERA_SCALE_CONSTRAINTS.x)
		#if event.button_index == 5:
			#camera_3d.spring_length = min(springArm.spring_length + 0.2, CAMERA_SCALE_CONSTRAINTS.y)
	

#
	#if Input.is_action_just_pressed("["):
		#cam_yaw.rotation.y -= deg_to_rad(45)
	#if Input.is_action_just_pressed("]"):
		#cam_yaw.rotation.y += deg_to_rad(45)
	#if Input.is_action_just_pressed("backslash"):
		#cam_pitch.rotation.x = 0
		#cam_yaw.rotation.y = 0
		#springArm.spring_length = 15
	#
	if Input.is_action_just_pressed("f"):
		lock_on_mode = !lock_on_mode
		
		#followers.pick_random().death()
		

func _process(_delta: float) -> void:
	if lock_on_mode and is_instance_valid(curr_target):
		if Input.is_action_pressed("left_click") and can_fire:
			can_fire = false
			firerate.start()
			var direction:Vector3 = (curr_target.global_position - gun_barrel.global_position).normalized()
			var scene = bullet_scene.instantiate()
			scene.position = gun_barrel.global_position
			scene.direction = direction
			scene.rotation = global_rotation
			scene.penetrating = true
			scene.damage = 5
			get_tree().root.add_child(scene)
	else:
		if Input.is_action_pressed("left_click") and can_fire:
			can_fire = false
			firerate.start()
			#var direction:Vector3 = (curr_target.global_position - gun_barrel.global_position).normalized()
			var scene = bullet_scene.instantiate()
			scene.position = gun_barrel.global_position
			scene.direction = Vector3.FORWARD.rotated(Vector3(0,1,0), global_rotation.y)
			scene.rotation = global_rotation
			get_tree().root.add_child(scene)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if lock_on_mode:
		if is_instance_valid(curr_target):
			look_at(curr_target.global_position)
		else:
			curr_target = find_closest_target()
	else:
		global_rotation.x = 0
		global_rotation.z = 0
	
	var input_dir := Input.get_vector("a", "d", "w", "s").rotated(-camera_3d.rotation.y)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		curr_acceleration = min(curr_acceleration + delta / 3, max_acceleration)
		velocity.x = direction.x * SPEED * curr_acceleration
		velocity.z = direction.z * SPEED * curr_acceleration
		#character.rotation.y = lerp_angle(character.rotation.y, atan2(-velocity.x, -velocity.z), 0.2)
	else:
		curr_acceleration = max(curr_acceleration - delta / 5, 0)


	move_and_slide()
	if Input.is_action_just_pressed("e") and is_instance_valid(interact_target):
		interact_target.interaction()

func find_closest_target() -> Node3D:
	var returnage #whatever will be returned, idfk
	var closest:float = INF
	for i in get_tree().get_nodes_in_group("Hostile"):
		if i.global_position.distance_to(global_position) < closest:
			returnage = i
			closest = i.global_position.distance_to(global_position)
	if returnage:
		return returnage
	return

#func teleport_allies_with_me() -> void:
	#for i in followers:
		#i.global_position = global_position
#
#func get_scrap(amount) -> int:
	#var old_scrap = curr_scrap
	#curr_scrap = min(max_scrap, curr_scrap + amount)
	#$CanvasLayer/Label.text = str("You are carrying: ", curr_scrap, "/", max_scrap, " scrap")
	#return curr_scrap - old_scrap
#
#func remove_scrap() -> int:
	#var old_amount:int = curr_scrap
	#curr_scrap = 0
	#$CanvasLayer/Label.text = str("You are carrying: ", curr_scrap, "/", max_scrap, " scrap")
	#return old_amount
#
#func signal_follow(body):
	#followers.append(body)
	#body.unit_index = follower_amount
	#follower_amount += 1
#
#func ally_died(body) -> void:
	#follower_amount -= 1
	#followers.erase(body)
	#var incrementer:int = 0
	#for i in followers:
		#i.unit_index = incrementer
		#incrementer += 1

func damage_func(amount:float) -> void:
	if can_be_hit:
		can_be_hit = false
		$MercyFrame.start()
		health -= amount
		health_label.text = str("Health: ", health, "/", max_health)
		if health <= 0:
			death()

func heal_func(amount:float) -> void:
	health = min(health + amount, max_health)
	health_label.text = str("Health: ", health, "/", max_health)

func death():
	print("You are dead. Now what?")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/overworld.tscn")

#func _on_area_3d_body_entered(body: Node3D) -> void:
	#if "damage_func" in body:
		#body.damage_func(8)
#

#func _on_hostile_seeker_body_entered(body: Node3D) -> void:
	#if body.is_in_group("Hostile"):
		#nearby_hostiles.append(body)
#
#
#func _on_hostile_seeker_body_exited(body: Node3D) -> void:
	#nearby_hostiles.erase(body)


func _on_mercy_frame_timeout() -> void:
	can_be_hit = true


func _on_firerate_timeout() -> void:
	can_fire = true
