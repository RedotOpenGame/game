extends GeneralEnemy

@export var attacking_range:float = 10
@onready var gun_barrel: Marker3D = $"mesh/Pistol?/GunBarrel"


var bullet_scene:PackedScene = preload("res://Scenes/entities/Projectiles/Enemy/enemy_bullet.tscn")

const spread:float = 25

var can_fire:bool = true

func _ready():
	# Get player from 'Player' group once at start
	health_label.text = str("Health: ", health, "/", max_health)

func _process(delta: float) -> void:
	if !is_on_floor():
		velocity += get_gravity() * delta
	if nearby_hostiles != []:
		curr_target = find_closest_target(hostile_seeker,"Ally")
	if is_instance_valid(curr_target):
		rotate_towards_target(curr_target.global_position,mesh,0.2)
		if global_position.distance_to(curr_target.global_position) > attacking_range:
			move_towards_target(curr_target.global_position,movement_speed)
		else:
			if can_fire:
				shoot()
	else:

		if global_position.distance_to(Vector3(spawned_point.x, global_position.y, spawned_point.z)) < movement_speed / 32:
			global_position = Vector3(spawned_point.x, global_position.y, spawned_point.z)
			velocity = Vector3(0, velocity.y, 0)
		else:
			move_towards_target(spawned_point,movement_speed)
			rotate_towards_target(spawned_point,mesh,0.2)
	for i in get_tree().get_nodes_in_group("Important"):
		if i.is_in_group("Ally"):
			if i not in nearby_hostiles:
				nearby_hostiles.append(i)
	move_and_slide()

func shoot() -> void:
	can_fire = false
	attackrate.start()
	for i in range(5):
		var scene = bullet_scene.instantiate()
		scene.position = gun_barrel.global_position
		scene.rotation = mesh.global_rotation
		scene.direction = (curr_target.global_position - gun_barrel.global_position).normalized().rotated(Vector3(0, 1, 0), deg_to_rad(randf_range(-spread, spread)))
		scene.damage = damage
		add_sibling(scene)

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

func heal_func(amount:float) -> void:
	health = min(health + amount, max_health)
	health_label.text = str("Health: ", health, "/", max_health)
		
func death() -> void:
	queue_free()

func _on_attackrate_timeout() -> void:
	can_fire = true
