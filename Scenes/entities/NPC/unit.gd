extends GeneralEntity
#class_name Unit

var resource_pile = preload("res://Scenes/misc/resource_pile.tscn")

@onready var health_label: Label3D = $HealthLabel

enum logic{FOLLOW_LEADER, ATTACK_ENEMY, IDLE, THROWN, RETURN, COLLECT}
enum unit_types{COMBAT,BUILDER,AGRI}
@export var throw_target: Vector3
@export var unit_type = unit_types.COMBAT
@export var throw_move_speed = {unit_types.BUILDER: 10, unit_types.AGRI: 5}
var curr_logic = logic.THROWN

@onready var type_showcase: Label3D = $TypeShowcase
@onready var attack_collision: CollisionShape3D = $characterMesh/DamageArea/AttackCollision
@onready var detection_collision: Area3D = $DetectionArea
@onready var attackrate: Timer = $Attackrate
@onready var ThrowTime: Timer = $ThrowTime
@onready var hitscan_preview: MeshInstance3D = $characterMesh/DamageArea/HitscanPreview
@export var throw_speed: float = 20
@onready var mesh = $characterMesh
@onready var ally_bot_2: Node3D = $characterMesh/AllyBot2
@onready var collision = $CollisionShape3D
@onready var player_owner: Label3D = $PlayerOwner
@onready var resources = 0
@export var max_resources: int

var _leader:Node3D #meant for multiplayer, in order for the only owner to collect them. Meant to be overwritten

#@export var row_spacing: float = 1.5
#@export var column_spacing: float = 1.5
@export var movement_speed: float = 4.0
var unit_index: int = 0  # Assign unique index to each unit
var is_collected:bool = false #need in order for not dupe.
var player_name:String = "Pewweper"

var curr_hostile:Node3D #find closest hostile.
var curr_recource: Node3D
@onready var resource_repo: Node3D

func _ready() -> void:
	health_label.text = str("Health: ", health, "/", max_health)

	if !_leader:
		push_error("Unit has no established leader node.")
		return
	#_leader.signal_follow(self)
	resource_repo = get_tree().get_first_node_in_group("ResourceRepo")
	if _leader.name != "PlayerActor":
		player_owner.visible = true
		player_owner.text = str("Owner: ", player_name)
	var displacement = throw_target - global_position
	var horizontal_displacement = Vector3(displacement.x, 0, displacement.z)
	ally_bot_2.set_type(unit_type)
	match (unit_type):
		unit_types.COMBAT:
			var vx = horizontal_displacement.x / 1
			var vz = horizontal_displacement.z / 1
			var vy = (displacement.y / 1) + (0.5 * ProjectSettings.get("physics/3d/default_gravity") * 1)
			velocity = Vector3(vx,vy,vz).limit_length(throw_speed)
			type_showcase.text = "TYPE: Combatant"
		unit_types.BUILDER:
			ThrowTime.wait_time = global_position.distance_to(throw_target) / throw_move_speed[unit_types.BUILDER]
			ThrowTime.start()
			type_showcase.text = "TYPE: Constructor"
		unit_types.AGRI:
			mesh.set_visible(false)
			collision_mask = 4
			ThrowTime.wait_time = global_position.distance_to(throw_target) / throw_move_speed[unit_types.AGRI]
			ThrowTime.start()
			type_showcase.text = "TYPE: Collector"


func _process(_delta: float):
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
		if(body.is_in_group("Resource") && curr_logic != logic.THROWN && curr_logic != logic.ATTACK_ENEMY && curr_logic != logic.RETURN):
			curr_logic = logic.COLLECT

func _physics_process(delta):
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
		logic.COLLECT:
			if(resources == 0):
				var recources = get_tree().get_nodes_in_group("Resource")
				if recources.is_empty() and resources == 0:
					curr_logic = logic.IDLE
				var current_position = global_position
				for recource in recources:
					# we really aught to just have a curr_target rather than curr_hostile/resource/etc and just run the target code - Awbluefy
					if not is_instance_valid(curr_recource):
						curr_recource = recource
					elif current_position.distance_to(recource.global_position) < current_position.distance_to(curr_recource.global_position):
						curr_recource = recource
				if(is_instance_valid(curr_recource)):
					var preffered_position = curr_recource.global_position
					var direction = (preffered_position - global_position).normalized()
					mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(-direction.x, -direction.z), 0.2)
					velocity.x = direction.x * movement_speed
					velocity.z = direction.z * movement_speed
			else:
				var preffered_position = resource_repo.global_position
				var direction = (preffered_position - global_position).normalized()
				mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(-direction.x, -direction.z), 0.2)
				velocity.x = direction.x * movement_speed
				velocity.z = direction.z * movement_speed
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
			var preffered_position = _leader.global_position
			var direction = (preffered_position - global_position).normalized()
			mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(-direction.x, -direction.z), 0.2)
			velocity.x = direction.x * movement_speed
			velocity.z = direction.z * movement_speed
	if not is_on_floor() and !(unit_type == unit_types.AGRI and curr_logic == logic.THROWN) and !collision.disabled:
		velocity += get_gravity() * delta
		#collision.disabled = false
	move_and_slide()
	

func heal_func(amount:float) -> void:
	health = min(health + amount, max_health)
	health_label.text = str("Health: ", health, "/", max_health)

func find_closest_target_2() -> Node3D:
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

@rpc("any_peer", "call_local")
func death_func() -> void:
	if resources > 0:
		var scene = resource_pile.instantiate()
		scene.position = global_position - Vector3(0, 0.6, 0)
		scene.scrap = resources
		add_sibling(scene)
	if is_instance_valid(_leader):
		_leader.ally_died(self)
	queue_free()


@onready var death_timer: Timer = $DeathTimer #needed for multiplayer


@rpc("any_peer", "call_local")
func collection(body) -> void:
	if "get_unit" in body and !is_collected:
		is_collected = true
		body.get_unit(1, unit_type)
		process_mode = Node.PROCESS_MODE_DISABLED
		var tween = get_tree().create_tween()
		tween.tween_property(mesh, "scale", Vector3(0.01, 0.01, 0.01), 0.5)
		await tween.finished
		#visible = false
		#remove_from_group("Ally")
		death_func.rpc()
		#var twee2 = get_tree().create_tween()
		#twee2.tween_property(mesh, "scale", Vector3(1, 1, 1), 1) #totally irrelevant, just needed to stall for info update for less errors.
		#print("last tween")
		#await twee2.finished
		#print("kill unit")
		


func _on_damage_area_body_entered(body: Node3D) -> void:
	if "damage_func" in body:
		body.damage_func(8)
		attack_collision.set_deferred("disabled", true)
		hitscan_preview.visible = false
		attackrate.start()
	if body.is_in_group("Resource"):
		#print("Resouce found")
		if(body.scrap - (max_resources - resources) > 0):
			body.scrap -= (max_resources - resources)
			resources = max_resources
		else:
			resources += body.scrap
			body.scrap = 0
			# I know this isnt the best way to do this part -Awbluefy
			body.queue_free()

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
			#collision.disabled = false
			collision_mask = 45
			velocity.y = 4
			
