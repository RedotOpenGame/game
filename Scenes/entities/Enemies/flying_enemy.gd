extends CharacterBody3D

@onready var health_label: Label3D = $HealthLabel
@onready var attackrate: Timer = $Attackrate
@onready var gun_barrel: Marker3D = $"Pistol?/GunBarrel"

var bullet_scene:PackedScene = preload("res://Scenes/entities/Projectiles/Enemy/enemy_bullet.tscn")

@export var movement_speed: float = 4.0

var nearby_hostiles:Array = []
var curr_target:Node3D
var can_fire:bool = true
@export var max_health:float = 40
@onready var health:float = max_health

func _ready():
	# Get player from 'Player' group once at start
	health_label.text = str("Health: ", health, "/", max_health)

func _process(delta: float) -> void:

	if nearby_hostiles != []:
		curr_target = find_closest_target()
	if is_instance_valid(curr_target):
		look_at(curr_target.global_position)
		if global_position.distance_to(curr_target.global_position) > 10:
			var preffered_position = curr_target.global_position
			var direction = (preffered_position - global_position).normalized()
			velocity.x = direction.x * movement_speed
			velocity.z = direction.z * movement_speed
		else:
			velocity.x = 0
			velocity.z = 0
			if can_fire:
				var preffered_position:Vector3 = curr_target.global_position
				var direction:Vector3 = (preffered_position - gun_barrel.global_position).normalized()
				var scene = bullet_scene.instantiate()
				scene.position = gun_barrel.global_position
				scene.direction = direction
				scene.rotation = global_rotation
				get_tree().root.add_child(scene)
				can_fire = false
				attackrate.start()
				
	for i in get_tree().get_nodes_in_group("Important"):
		if i.is_in_group("Ally"):
			if i not in nearby_hostiles:
				nearby_hostiles.append(i)
	move_and_slide()



func find_closest_target() -> Node3D:
	var returnage #whatever will be returned, idfk
	var closest:float = INF
	for i in nearby_hostiles:
		if i.global_position.distance_to(global_position) < closest:
			returnage = i
			closest = i.global_position.distance_to(global_position)
	if returnage:
		return returnage
	return self

func _on_hostile_seeker_body_entered(body: Node3D) -> void:
	if body.is_in_group("Ally"):
		nearby_hostiles.append(body)


func _on_hostile_seeker_body_exited(body: Node3D) -> void:
	nearby_hostiles.erase(body)
	if curr_target == body:
		curr_target = null

func damage_func(amount:float) -> void:
	health -= amount
	health_label.text = str("Health: ", health, "/", max_health)
	if health <= 0:
		death()
		
		
func death() -> void:
	queue_free()

func _on_attackrate_timeout() -> void:
	can_fire = true
