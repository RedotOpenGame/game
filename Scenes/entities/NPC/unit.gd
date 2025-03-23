extends CharacterBody3D

@onready var health_label: Label3D = $HealthLabel

enum logic{FOLLOW_LEADER, ATTACK_ENEMY, IDLE, THROWN, RETURN}
enum unit_types{COMBAT,BUILDER,AGRI}
@export var throw_target: Vector3
@export var unit_type = unit_types.COMBAT
@export var throw_move_speed = {unit_types.BUILDER: 10, unit_types.AGRI: 5}
var curr_logic = logic.THROWN

@onready var attack_collision: CollisionShape3D = $characterMesh/DamageArea/AttackCollision
@onready var detection_collision: Area3D = $DetectionArea
@onready var attackrate: Timer = $Attackrate
@onready var ThrowTime: Timer = $ThrowTime
@onready var hitscan_preview: MeshInstance3D = $characterMesh/DamageArea/HitscanPreview
@export var throw_speed: float
@onready var mesh = $characterMesh
@onready var collision = $CollisionShape3D
@onready var player
var _leader:Node3D

#@export var row_spacing: float = 1.5
#@export var column_spacing: float = 1.5
@export var movement_speed: float = 4.0
var unit_index: int = 0  # Assign unique index to each unit

var max_health:float = 40
var health:float = max_health

var curr_hostile:Node3D #find closest hostile.

func _ready():
	# Get player from 'Player' group once at start
	player = get_tree().get_first_node_in_group("Player")
	
	health_label.text = str("Health: ", health, "/", max_health)
	#_leader = 
	#if !_leader:
		##push_error("No player found in 'Player' group")
		#return
	#_leader.signal_follow(self)
	var displacement = throw_target - global_position
	var horizontal_displacement = Vector3(displacement.x, 0, displacement.z)
	match (unit_type):
		unit_types.COMBAT:
			var vx = horizontal_displacement.x / 1
			var vz = horizontal_displacement.z / 1
			var vy = (displacement.y / 1) + (0.5 * ProjectSettings.get("physics/3d/default_gravity") * 1)
			velocity = Vector3(vx,vy,vz)
		unit_types.BUILDER:
			ThrowTime.wait_time = global_position.distance_to(throw_target) / throw_move_speed[unit_types.BUILDER]
			ThrowTime.start()
		unit_types.AGRI:
			mesh.set_visible(false)
			collision.disabled = true
			ThrowTime.wait_time = global_position.distance_to(throw_target) / throw_move_speed[unit_types.AGRI]
			ThrowTime.start()
	
	

func _physics_process(delta):
		
	# Calculate row and column position in formation
	#change_logic()
		# This is some logic for the follower functionality if we want to add it back in later
		#if curr_logic == logic.FOLLOW_LEADER:
		#var r := int((sqrt(8 * unit_index + 1) - 1) / 2)
		#var c := unit_index - (r * (r + 1)) / 2
		#
		## Calculate horizontal offset for symmetrical placement
		#var horizontal_offset := (c - r / 2.0) * column_spacing
		#
		## Calculate target position relative to leader
		#var preffered_position = _leader.global_position + Vector3(horizontal_offset, 0, (r + 1) * row_spacing).rotated(Vector3(0, 1, 0), _leader.cam_yaw.global_rotation.y)
		#var direction = (preffered_position - global_position).normalized()
		#
		#if global_position.distance_to(preffered_position) < movement_speed / 32:
			#global_position = preffered_position
			#velocity = Vector3(0, 0, 0)
		#else:
			#velocity = direction * movement_speed
	
	match(curr_logic):
		logic.ATTACK_ENEMY:
			#curr_hostile = find_closest_target()
			if(is_instance_valid(curr_hostile)):
				var preffered_position = curr_hostile.global_position
				var direction = (preffered_position - global_position).normalized()
				mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(-direction.x, -direction.z), 0.2)
				velocity.x = direction.x * movement_speed
				velocity.z = direction.z * movement_speed
			else:
				curr_logic = logic.IDLE
		logic.THROWN:
			match(unit_type):
				unit_types.COMBAT:
					if(is_on_floor()):
						curr_logic = logic.IDLE
				unit_types.BUILDER:	
					var forwards = -mesh.transform.basis.z.normalized()
					velocity.x = forwards.x * throw_move_speed[unit_types.BUILDER]
					velocity.z = forwards.z * throw_move_speed[unit_types.BUILDER]
				unit_types.AGRI:
					var forwards = -mesh.transform.basis.z.normalized()
					velocity = forwards * throw_move_speed[unit_types.AGRI]
			mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(-velocity.x, -velocity.z), 0.2)
		logic.IDLE:
			if is_on_floor() and ThrowTime.is_stopped():
				velocity.x = 0
				velocity.z = 0
		logic.RETURN:
			var preffered_position = player.global_position
			var direction = (preffered_position - global_position).normalized()
			mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(-direction.x, -direction.z), 0.2)
			velocity.x = direction.x * movement_speed
			velocity.z = direction.z * movement_speed
			
		#logic.FOLLOW_LEADER:
			#var preffered_position = _leader.global_position
			#var direction = (preffered_position - global_position).normalized()
			#
			#if global_position.distance_to(preffered_position) < movement_speed / 32:
				#global_position = preffered_position
				#velocity = Vector3(0, 0, 0)
			#else:
				#velocity = direction * movement_speed
	#change_logic()


		#print(global_position.distance_to(preffered_position))
	#var target_position := _leader.global_transform.origin \
		#+ (_leader.global_transform.basis.z * (r + 1) * row_spacing \
		#+ _leader.global_transform.basis.x * horizontal_offset).rotated(Vector3(0, 1, 0), _leader.camera_control.global_rotation.y)
	#
	## Smoothly move towards target position
	#global_transform.origin = global_transform.origin.move_toward(
		#target_position,
		#movement_speed * delta
	#)
	if not is_on_floor() and !(unit_type == unit_types.AGRI and curr_logic == logic.THROWN):
		velocity += get_gravity() * delta
	move_and_slide()

func _process(_delta: float):
	#if(velocity.x != 0 && velocity.z != 0):
		#mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(-velocity.x, -velocity.z), 0.2)
	
	var bodies = detection_collision.get_overlapping_bodies()
	for body in bodies:
		if(body.is_in_group("Hostile") && curr_logic != logic.THROWN):
			var current_position = global_position
			curr_logic = logic.ATTACK_ENEMY
			if(is_instance_valid(curr_hostile)):
				if(current_position.distance_to(body.global_position) < current_position.distance_to(curr_hostile.global_position)):
					curr_hostile = body
			else:
				curr_hostile = body
			

func heal_func(amount:float) -> void:
	health = min(health + amount, max_health)
	health_label.text = str("Health: ", health, "/", max_health)


#func change_logic() -> void:
	#if _leader.nearby_hostiles != []:
		#curr_logic = logic.ATTACK_ENEMY
		#return
	#curr_logic = logic.FOLLOW_LEADER
	

func find_closest_target() -> Node3D:
	var returnage #whatever will be returned, idfk
	var closest:float = INF
	for i in _leader.nearby_hostiles:
		if i.global_position.distance_to(global_position) < closest:
			returnage = i
			closest = i.global_position.distance_to(global_position)
	if returnage:
		return returnage
	return self




func damage_func(amount:float) -> void:
	health -= amount
	health_label.text = str("Health: ", health, "/", max_health)
	if health <= 0:
		death()

func throw() -> void:
	velocity += Vector3(20, 20, 0).rotated(Vector3(0, 1, 0), _leader.camera_control.global_rotation.y) #NOT WORKING RN
	print("throwing")

func death() -> void:
	if is_instance_valid(_leader):
		_leader.ally_died(self)
	queue_free()


func _on_damage_area_body_entered(body: Node3D) -> void:
	if "damage_func" in body:
		body.damage_func(8)
		attack_collision.set_deferred("disabled", true)
		hitscan_preview.visible = false
		attackrate.start()

func _on_attackrate_timeout() -> void:
	attack_collision.disabled = false
	hitscan_preview.visible = true


func _on_throw_time_timeout() -> void:
	match(unit_type):
		unit_types.BUILDER:
			curr_logic = logic.IDLE
		unit_types.AGRI:
			curr_logic = logic.IDLE
			mesh.set_visible(true)
			collision.disabled = false
			velocity.y = 4
			
