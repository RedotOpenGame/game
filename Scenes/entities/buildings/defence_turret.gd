extends CharacterBody3D

var bullet = preload("res://Scenes/entities/Projectiles/Player/bullet.tscn")
@onready var barrel: Node3D = $Barrel

@onready var health_label: Label3D = $HealthLabel
@onready var firerate: Timer = $Firerate
@onready var marker_3d: Marker3D = $Barrel/Marker3D

@export var max_health:float = 40
@onready var health:float = max_health

var nearby_hostiles:Array = []
var curr_target:Node3D
var can_fire:bool = true

func _ready():
	health_label.text = str("Health: ", health, "/", max_health)

func _process(delta: float) -> void:
	curr_target = find_closest_target()
	if is_instance_valid(curr_target):
		barrel.look_at(curr_target.global_position)
		if can_fire:
			shoot()

func shoot() -> void:
	can_fire = false
	firerate.start()
	var direction:Vector3 = (curr_target.global_position - barrel.global_position).normalized()
	var scene = bullet.instantiate()
	scene.position = marker_3d.global_position
	scene.rotation = barrel.global_rotation
	scene.direction = direction
	add_sibling(scene)

func damage_func(amount:float) -> void:
	health -= amount
	health_label.text = str("Health: ", health, "/", max_health)
	if health <= 0:
		death()

func heal_func(amount:float) -> void:
	health = min(health + amount, max_health)
	health_label.text = str("Health: ", health, "/", max_health)

func death() -> void:
	queue_free()

func _on_hostile_seeker_body_entered(body: Node3D) -> void:
	if body.is_in_group("Hostile"):
		nearby_hostiles.append(body)

func _on_hostile_seeker_body_exited(body: Node3D) -> void:
	nearby_hostiles.erase(body)
	if curr_target == body:
		curr_target = null

func find_closest_target():
	var returnage #whatever will be returned, idfk
	var closest:float = INF
	for i in nearby_hostiles:
		if i.global_position.distance_to(global_position) < closest:
			returnage = i
			closest = i.global_position.distance_to(global_position)
	if returnage:
		return returnage
	return null

func _on_firerate_timeout() -> void:
	can_fire = true
