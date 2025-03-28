extends CharacterBody3D

var bullet_scene = preload("res://Scenes/entities/Projectiles/Enemy/enemy_bullet.tscn")

@onready var mesh: Node3D = $mesh

@onready var steyr_aug: Node3D = $mesh/steyr_aug

@onready var reloading_label: Label3D = $ReloadingLabel
@onready var health_label: Label3D = $HealthLabel
@onready var gun_barrel: Marker3D = $mesh/steyr_aug/GunBarrel
@onready var firerate: Timer = $Firerate
@onready var reload: Timer = $Reload
@onready var jump: Timer = $Jump

var Jump_power:float = 8
var speed:float = 4
var retreat_speed:float = 2
var max_health:float = 1000
var health:float = max_health
var curr_target:Node3D

const max_ammo:int = 30
var ammo:int = max_ammo
var can_fire:bool = true
var reloading:bool = false
var damage:float = 5.0

var double_jump:bool = true

func _ready():
	health_label.text = str("Health: ", health, "/", max_health)
	reloading_label.visible = reloading # make the label dissapear

func _process(delta: float) -> void:
	if !is_on_floor():
		velocity += get_gravity() * delta
	curr_target = find_closest_target()
	reloading_label.text = str("Reloading: ", snapped(reload.time_left, 0.01))
	if is_instance_valid(curr_target):
		mesh.look_at(Vector3(curr_target.global_position.x, global_position.y, curr_target.global_position.z))
		var preffered_position = curr_target.global_position
		var direction = (preffered_position - global_position).normalized()
		if global_position.distance_to(curr_target.global_position) > 20:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = direction.x * -retreat_speed
			velocity.z = direction.x * -retreat_speed
			if ammo > 0:
				if can_fire:
					ammo -= 1
					var bullet_direction:Vector3 = (preffered_position - gun_barrel.global_position).normalized()
					var scene = bullet_scene.instantiate()
					scene.position = gun_barrel.global_position
					scene.direction = bullet_direction
					scene.rotation = mesh.global_rotation
					scene.damage = damage
					get_tree().root.add_child(scene)
					can_fire = false
					firerate.start()
			else:
				if !reloading:
					reload.start()
				reloading = true
				reloading_label.visible = reloading
				
	move_and_slide()



func find_closest_target():
	var returnage #whatever will be returned, idfk
	var closest:float = INF
	for i in get_tree().get_nodes_in_group("Ally"):
		if i.global_position.distance_to(global_position) < closest:
			returnage = i
			closest = i.global_position.distance_to(global_position)
	if returnage:
		return returnage
	return 


func damage_func(amount:float) -> void:
	health -= amount
	health_label.text = str("Health: ", health, "/", max_health)
	if health <= 0:
		death()
		
		
func death() -> void:
	queue_free()

func _on_reload_timeout() -> void:
	reloading = false
	ammo = max_ammo
	reloading_label.visible = reloading


func _on_firerate_timeout() -> void:
	can_fire = true


func _on_jump_timeout() -> void:
	if is_on_floor():
		velocity.y = Jump_power
		double_jump = true
	elif double_jump:
		velocity.y = Jump_power
		double_jump = false
	jump.start(randf_range(0.5, 3))
