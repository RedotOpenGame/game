extends CharacterBody3D

var bus_index_music:int
var bus_index_sound:int
var sound_bus_name:String = "SFX"
var music_bus_name:String = "Music"

var starting_building:PackedScene = preload("res://Scenes/entities/buildings/starting_building.tscn")
var starting_building_placed:bool = false
var building_blueprint:PackedScene = preload("res://Scenes/entities/buildings/blueprint_box.tscn")
@onready var build_help: Label = $CanvasLayer/BuildHelp
@onready var modular_guns: Node3D = $characterMesh/ModularGuns

@onready var multi_sync: MultiplayerSynchronizer = $MultiplayerSynchronizer

@onready var building_marker: Marker3D = $characterMesh/BuildingMarker

@onready var hostile_seeker: Area3D = $HostileSeeker
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var health_label: Label = $CanvasLayer/Health
@onready var music_volume: HSlider = $CanvasLayer/Pausemenu/MusicVolume
@onready var pausemenu: Control = $CanvasLayer/Pausemenu

enum unit_types{COMBAT,BUILDER,AGRI}

@export var combatant_amount:int = 10
@export var builder_amount:int = 10
@export var agriculture_amount:int = 10

@onready var throw_location: Node3D = $characterMesh/ThrowLocation
@onready var throw_position_showcase: MeshInstance3D = $ThrowPositionShowcase
@onready var canvas_layer: CanvasLayer = $CanvasLayer

@onready var combatant_amount_label: Label = $CanvasLayer/Labels/CombatantAmount
@onready var constructor_amount_label: Label = $CanvasLayer/Labels/ConstructorAmount
@onready var collectors_amount_label: Label = $CanvasLayer/Labels/CollectorsAmount

@onready var unit_collection_collision: CollisionShape3D = $CollectUnits/CollisionShape3D
@onready var is_collecting_units: Label = $CanvasLayer/Labels/IsCollectingUnits
@onready var unit_call_collision: Area3D = $CallUnits
@onready var camera: Camera3D = $CameraControl/Yaw/Pitch/SpringArm3D/Camera3D
@onready var cam_yaw = $CameraControl/Yaw
@onready var cam_pitch = $CameraControl/Yaw/Pitch
@onready var camera_control: Node3D = $CameraControl
@onready var springArm = $CameraControl/Yaw/Pitch/SpringArm3D
@onready var character = $characterMesh
@onready var selected_unit_type = -1
@export var SPEED = 6.5
var JUMP_VELOCITY = 9.5
const CAMERA_CONSTRAITS:Vector2 = Vector2(90, 180) #constraints for up and down camera movement(which doesn't let you look upwards)
const CAMERA_SCALE_CONSTRAINTS:Vector2 = Vector2(4, 40.0) #how far or close the camera may be
var max_health:float = 100.0
var health:float = max_health
var can_be_hit:bool = true

var curr_scrap:int = 0
var max_scrap:int = 3

var interactables_in_range:Array = []
var followers:Array = [] 
var follower_amount:int = 0
var ignore_first_input:bool = true

var unit = preload("res://Scenes/entities/NPC/unit.tscn")

var nearby_hostiles:Array = []

func _ready() -> void:
	bus_index_music = AudioServer.get_bus_index("Music")
	bus_index_sound = AudioServer.get_bus_index(sound_bus_name)
	var value = AudioServer.get_bus_volume_db(bus_index_music)
	music_volume.set_value_no_signal(db_to_linear(value))
	camera.current = false
	Gameplay.scrap = 0 #reset scrap every time player spawns... Oh. I don't think this should stay here, but for now, this is enough.
	health_label.text = str("Health: ", health, "/", max_health)
	combatant_amount_label.text = str("Combatant units: ", combatant_amount)
	constructor_amount_label.text = str("Constructor units: ", builder_amount)
	collectors_amount_label.text = str("Collector units: ", agriculture_amount)
	is_collecting_units.text = str("Is collecting units: ", !unit_collection_collision.disabled)
	build_help.visible = false
	throw_position_showcase.visible = false
	pausemenu.visible = Gameplay.paused
	if str(name) == "PlayerActor":
		camera.make_current()
		pass
	else:
		multi_sync.set_multiplayer_authority(str(name).to_int())
		
		if multi_sync.get_multiplayer_authority() == multiplayer.get_unique_id():
			camera.make_current()
			canvas_layer.visible = true
		else:
			camera.current = false
			canvas_layer.visible = false

func _input(event: InputEvent) -> void:
	if name == "PlayerActor":
		pass
	elif multi_sync.get_multiplayer_authority() != multiplayer.get_unique_id(): return
	
	if event is InputEventMouseMotion and Input.is_action_pressed("right_click"):
		if !ignore_first_input:
			cam_yaw.rotate_y(deg_to_rad(-event.relative.x * 0.5))
			cam_pitch.rotate_x(deg_to_rad(-event.relative.y * 0.5))
			cam_pitch.rotation.x = clamp(cam_pitch.rotation.x, deg_to_rad(-CAMERA_CONSTRAITS.x), deg_to_rad(180))
		else:
			ignore_first_input = false
	if event is InputEventMouseButton:
		if event.button_index == 4: #scroll back
			springArm.spring_length = max(springArm.spring_length - 0.2, CAMERA_SCALE_CONSTRAINTS.x)
		if event.button_index == 5: #scroll forward
			springArm.spring_length = min(springArm.spring_length + 0.2, CAMERA_SCALE_CONSTRAINTS.y)
	
	if Input.is_action_just_released("right_click"): 
		ignore_first_input = true

	if Input.is_action_just_pressed("["):
		cam_yaw.rotation.y -= deg_to_rad(45)
	if Input.is_action_just_pressed("]"):
		cam_yaw.rotation.y += deg_to_rad(45)
	if Input.is_action_just_pressed("backslash"): #return camera to normal position
		cam_pitch.rotation.x = 0
		cam_yaw.rotation.y = 0
		springArm.spring_length = 15
	
	if Input.is_action_just_pressed("f"): #turn on/off unit collection
		unit_collection_collision.set_deferred("disabled", !unit_collection_collision.disabled)
		is_collecting_units.text = str("Is collecting units: ", unit_collection_collision.disabled)
	if Input.is_action_just_pressed("z"): #Calling all units
		call_all_units.rpc()
	if Input.is_action_just_pressed("v") and !starting_building_placed:
		starting_building_placed = true
		var scene = starting_building.instantiate()
		scene.position = building_marker.global_position
		scene.rotation = character.global_rotation
		add_sibling(scene)
	if Input.is_action_just_pressed("x"):
		if building_marker.get_child_count() != 0:
			var node = building_marker.get_child(0)
			node.process_mode = Node.PROCESS_MODE_ALWAYS
			node.reparent(get_tree().get_first_node_in_group("AllyContainer"))
			build_help.visible = false
	if Input.is_action_just_pressed("m"):
		if music_volume.value != 0:
			music_volume.value = 0
		else:
			music_volume.value = 1
		#followers.pick_random().death()
	#Temporarily implimentation: select unit type
	if Input.is_key_pressed(KEY_1):
		selected_unit_type = -1
		throw_position_showcase.visible = false
	if Input.is_key_pressed(KEY_2):
		selected_unit_type = unit_types.COMBAT
		throw_position_showcase.visible = true
		throw_position_showcase.mesh["material"]["emission"] = Color.RED
		throw_position_showcase.mesh["material"]["albedo_color"] = Color.RED
	if Input.is_key_pressed(KEY_3):
		selected_unit_type = unit_types.BUILDER
		throw_position_showcase.visible = true
		throw_position_showcase.mesh["material"]["emission"] = Color.BLUE
		throw_position_showcase.mesh["material"]["albedo_color"] = Color.BLUE
	if Input.is_key_pressed(KEY_4):
		selected_unit_type = unit_types.AGRI
		throw_position_showcase.visible = true
		throw_position_showcase.mesh["material"]["emission"] = Color.GREEN
		throw_position_showcase.mesh["material"]["albedo_color"] = Color.GREEN
	if Input.is_action_just_pressed("f11"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if Input.is_action_just_pressed("esc"):
		Gameplay.paused = !Gameplay.paused
		pausemenu.visible = Gameplay.paused
		if Gameplay.paused:
			Engine.time_scale = 0.0001
		else:
			Engine.time_scale = 1

func _process(_delta: float) -> void:
	if name == "PlayerActor":
		pass
	elif multi_sync.get_multiplayer_authority() != multiplayer.get_unique_id(): return
		
	var target_plane_mouse = Plane(Vector3(0, 1, 0), position.y)
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var cursor_pos_on_plane = target_plane_mouse.intersects_ray(from, to)
	var params = PhysicsRayQueryParameters3D.new()
	params.from = from
	params.to = to
	var collision = get_world_3d().direct_space_state.intersect_ray(params)
	var target_point = collision.position if collision else to
	if target_point:
		throw_position_showcase.global_position = target_point
		
	if Input.is_action_pressed("left_click") and !Gameplay.paused:
		anim.play("attack")
		if target_point:
			for i in modular_guns.get_children():
				i.shoot(target_point)
			character.look_at(target_point)
			if(Input.is_action_just_pressed("left_click") and selected_unit_type != -1 and !(!is_on_floor() and selected_unit_type == unit_types.AGRI)):
				unit_throw.rpc(target_point)

	if(Input.is_action_pressed("e")):
		if cursor_pos_on_plane:
			unit_call_collision.global_position = cursor_pos_on_plane
			if(!unit_call_collision.visible):
				unit_call_collision.set_visible(true)
	else:
		unit_call_collision.set_visible(false)

@rpc("any_peer", "call_local")
func unit_throw(cursor_pos_on_plane) -> void:
				var instance = unit.instantiate()
				match selected_unit_type:
					unit_types.COMBAT:
						if combatant_amount > 0:
							combatant_amount -= 1
							combatant_amount_label.text = str("Combatant units: ", combatant_amount)
						else:
							return
					unit_types.BUILDER:
						if builder_amount > 0:
							builder_amount -= 1
							constructor_amount_label.text = str("Constructor units: ", builder_amount)
						else:
							return
					unit_types.AGRI:
						if agriculture_amount > 0:
							agriculture_amount -= 1
							collectors_amount_label.text = str("Collector units: ", agriculture_amount)
						else:
							return
				instance._leader = self
				instance.position = throw_location.global_position
				instance.throw_target = cursor_pos_on_plane
				instance.unit_type = selected_unit_type
				add_sibling(instance)
				instance.get_node("characterMesh").rotation.y = character.rotation.y

func _physics_process(delta: float) -> void:
	if name == "PlayerActor":
		pass
	elif multi_sync.get_multiplayer_authority() != multiplayer.get_unique_id(): return
			
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

		# Handle jump.
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As bad practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("a", "d", "w", "s").rotated(-cam_yaw.rotation.y)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and !Gameplay.paused:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		character.rotation.y = lerp_angle(character.rotation.y, atan2(-velocity.x, -velocity.z), 0.2)
		character.rotation.x = 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	if Input.is_action_just_pressed("e") and interactables_in_range != []:
		var interact_target:Node3D
		var closest:float = INF
		for i in interactables_in_range:
			if global_position.distance_to(i.global_position) < closest:
				closest = global_position.distance_to(i.global_position)
				interact_target = i
		interact_target.interaction()

@rpc("any_peer", "call_local")
func call_all_units() -> void:
	for i in get_tree().get_nodes_in_group("Unit"):
		if i._leader == self:
			i.curr_logic = 4

func teleport_allies_with_me() -> void:
	for i in followers:
		i.global_position = global_position

func get_scrap(amount) -> int:
	var old_scrap = curr_scrap
	curr_scrap = min(max_scrap, curr_scrap + amount)
	$CanvasLayer/Label.text = str("You are carrying: ", curr_scrap, "/", max_scrap, " scrap")
	return curr_scrap - old_scrap

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
	if can_be_hit:
		if health > 0:
			can_be_hit = false
			$MercyFrame.start()
			health -= amount
			health_label.text = str("Health: ", health, "/", max_health)
		else:
			death()

func heal_func(amount:float) -> void:
	health = min(health + amount, max_health)
	health_label.text = str("Health: ", health, "/", max_health)

@rpc("any_peer", "call_local")
func death():
	print("You are dead. Wait for respawn.")
	remove_from_group("Ally")
	SPEED = 0
	character.visible = false
	JUMP_VELOCITY = 0
	collision_mask = 4
	$Respawn.start()
	$characterMesh/DamageArea.monitoring = false
	can_be_hit = false
	#get_tree().call_deferred("change_scene_to_file", "res://Scenes/overworld.tscn")

func _on_respawn_timeout() -> void:
	respawn_func.rpc()

@rpc("any_peer", "call_local")
func respawn_func() -> void:
	add_to_group("Ally")
	character.visible = true
	SPEED = 6.5
	JUMP_VELOCITY = 9.5
	collision_mask = 45
	$characterMesh/DamageArea.monitoring = true
	health = max_health
	health_label.text = str("Health: ", health, "/", max_health)
	can_be_hit = true

func add_interactable(node:Node3D) -> void:
	interactables_in_range.append(node)

func remove_interactable(node:Node3D) -> void:
	interactables_in_range.erase(node)

func get_blueprint(scene:PackedScene, build_name:String, constructor_req:int, build_cost:int) -> void:
	var blueprint = building_blueprint.instantiate()
	blueprint.planned_bulding = scene
	blueprint.process_mode = Node.PROCESS_MODE_DISABLED
	blueprint.unit_req = constructor_req
	blueprint.build_cost = build_cost
	blueprint.build_name = build_name
	building_marker.add_child(blueprint)
	build_help.visible = true


func _on_area_3d_body_entered(body: Node3D) -> void:
	if "damage_func" in body:
		body.damage_func(8)

func _on_hostile_seeker_body_entered(body: Node3D) -> void:
	if body.is_in_group("Hostile"):
		nearby_hostiles.append(body)

func _on_hostile_seeker_body_exited(body: Node3D) -> void:
	nearby_hostiles.erase(body)

func _on_mercy_frame_timeout() -> void:
	can_be_hit = true

@rpc("call_local")
func get_unit(amount, type) -> void:
	match type:
		0: #combatants
			#print("getting ", amount, " combatant")
			combatant_amount += amount
			combatant_amount_label.text = str("Combatant units: ", combatant_amount)
		1:
			#print("getting ", amount, " builder")
			builder_amount += amount
			constructor_amount_label.text = str("Constructor units: ", builder_amount)
		2:
			#print("getting ", amount, " agri")
			agriculture_amount += amount
			collectors_amount_label.text = str("Collector units: ", agriculture_amount)

func _on_collect_units_body_entered(body: Node3D) -> void:
	if(body.is_in_group("Unit") and (body.curr_logic == 4 or body.curr_logic == 2) and body._leader == self and !body.is_collected):
		match body.unit_type:
			0:
				body.collection.rpc(self)
				#body.is_collected = true
				#body.death_func.rpc()
			1:
				get_unit.rpc(1, body.unit_type)
				body.is_collected = true
				body.death_func.rpc()
			2:
				get_unit.rpc(1, body.unit_type)
				body.is_collected = true
				body.death_func.rpc()


func _on_call_units_body_entered(body: Node3D) -> void:
	if(body.is_in_group("Unit") and Input.is_action_pressed("e") and body._leader == self):
		body.curr_logic = 4


func _on_music_volume_value_changed(value: float) -> void:
			AudioServer.set_bus_volume_db(
			bus_index_music,
			linear_to_db(value)
			)

func add_module(scene:PackedScene) -> bool:
	var inst = scene.instantiate()
	for i in modular_guns.get_children():
		if inst.name == i.name:
			return false
	modular_guns.add_child(inst)
	return true

func _on_resune_pressed() -> void:
	Gameplay.paused = false
	pausemenu.visible = Gameplay.paused
	if Gameplay.paused:
		Engine.time_scale = 0.0001
	else:
		Engine.time_scale = 1
