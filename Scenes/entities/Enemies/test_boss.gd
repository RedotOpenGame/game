extends GeneralEnemy


@onready var gun_barrel: Marker3D = $"Pistol?/GunBarrel"


var bullet_scene:PackedScene = preload("res://Scenes/entities/Projectiles/Enemy/enemy_bullet.tscn")

const spread:float = 30

var can_fire:bool = true

func _ready():
	# Get player from 'Player' group once at start
	health_label.text = str("Health: ", health, "/", max_health)


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
