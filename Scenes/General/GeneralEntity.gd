extends CharacterBody3D
#
# This is our primary class for characters in the game, mostly including functionality for handling damage in combat scenarios
# Handling autonomous targeting and movement, as well as other combat things. 
# Not every subclass will necessarily use every function but this will generally have things that are nice to have on entities. 
#

class_name GeneralEntity

@export var max_health:float = 100.0
@onready var health:float = max_health
@onready var curr_scrap:int = 0
@export var max_scrap:int = 3

func damage_func(amount:float) -> void:
	health -= amount
	if health <= 0:
		death()

func heal_func(amount:float) -> void:
	health = min(health + amount, max_health)

func death():
	queue_free()

func find_closest_target(targetArea: Area3D, targetTag: String) -> CharacterBody3D:
	var bodies = targetArea.get_overlapping_bodies()
	#if bodies.is_empty():
		#return null
	var closest:float = INF

	var current_position = global_position
	var returnEntity = null
	var importants = get_tree().get_nodes_in_group("Important") #like townhall for survival mode.
	if !importants.is_empty():
		for i in importants:
			if i.is_in_group(targetTag) and current_position.distance_to(i.global_position) < closest:
				returnEntity = i
				closest = current_position.distance_to(i.global_position)
	for body in bodies:
		if body.is_in_group(targetTag) and current_position.distance_to(body.global_position) < closest:
			returnEntity = body
			closest = current_position.distance_to(body.global_position)
	return returnEntity
	
func find_closest_global_target(targetTag: String) -> GeneralEntity:
	var bodies = get_tree().get_nodes_in_group(targetTag)
	if bodies.is_empty():
		return null
	var returnEntity = bodies.front()
	var current_position = global_position
	for body in bodies:
		if current_position.distance_to(body.global_position) < current_position.distance_to(returnEntity.global_position):
			returnEntity = body
	return returnEntity

func move_towards_target(targetPos: Vector3, speed: float):
	var direction = (targetPos - global_position).normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
func rotate_towards_target(targetPos: Vector3, rotationNode: Node3D, lerpVal: float):
	var direction = (targetPos - global_position).normalized()
	if(rotationNode != null):
		rotationNode.rotation.y = lerp_angle(rotationNode.rotation.y, atan2(-direction.x, -direction.z), lerpVal)

func get_scrap(amount) -> int:
	var old_scrap = curr_scrap
	curr_scrap = min(max_scrap, curr_scrap + amount)
	return curr_scrap - old_scrap
