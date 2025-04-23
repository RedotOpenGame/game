extends GeneralEntity


const max_optimization:int = 10
var optim:int = max_optimization
const bullet_scene:PackedScene = preload("res://Scenes/entities/Projectiles/Enemy/enemy_bullet.tscn")

@onready var mesh: Node3D = $mesh

@onready var steyr_aug: Node3D = $mesh/steyr_aug

@onready var reloading_label: Label3D = $ReloadingLabel
@onready var hostile_seeker: Area3D = $HostileSeeker
@onready var health_label: Label3D = $HealthLabel
@onready var gun_barrel: Marker3D = $mesh/steyr_aug/GunBarrel
@onready var firerate: Timer = $Firerate
@onready var reload: Timer = $Reload
@onready var jump: Timer = $Jump

const Jump_power:float = 8
const speed:float = 4
const retreat_speed:float = 2
var curr_target:Node3D

const max_ammo:int = 30
var ammo:int = max_ammo
var can_fire:bool = true
var reloading:bool = false
const damage:float = 5.0

var double_jump:bool = true

func _ready():
	health_label.text = str("Health: ", health, "/", max_health)
	reloading_label.visible = reloading # make the label dissapear

func _process(delta: float) -> void:
	if !is_on_floor():
		velocity += get_gravity() * delta
	
	optim -= 1
	if optim <= 0:
		curr_target = find_closest_global_target("Ally")
		optim = max_optimization
	reloading_label.text = str("Reloading: ", snapped(reload.time_left, 0.01))
	
	if is_instance_valid(curr_target):
		mesh.look_at(Vector3(curr_target.global_position.x, global_position.y, curr_target.global_position.z))
		var direction:Vector3 = (curr_target.global_position - global_position).normalized()
		if global_position.distance_to(curr_target.global_position) > 20:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = direction.x * -retreat_speed
			velocity.z = direction.x * -retreat_speed
			shoot(curr_target.global_position)
		move_and_slide()

	

func shoot(pos:Vector3) -> void:
	if ammo > 0:
		if can_fire:
			ammo -= 1
			can_fire = false
			firerate.start()
			var bullet_direction:Vector3 = (pos - gun_barrel.global_position).normalized()
			var scene:Area3D = bullet_scene.instantiate()
			scene.position = gun_barrel.global_position
			scene.direction = bullet_direction
			scene.rotation = mesh.global_rotation
			scene.damage = damage
			get_tree().current_scene.add_child(scene)
			
			
	else:
		if !reloading:
			reload.start()
			reloading = true
			reloading_label.visible = reloading


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
