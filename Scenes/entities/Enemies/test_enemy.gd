extends GeneralEntity
class_name GeneralEnemy
@onready var health_label: Label3D = $HealthLabel
@onready var attack_collision: CollisionShape3D = $mesh/enemy_bot/DamageArea/AttackCollision
@onready var hitscan_preview: MeshInstance3D = $mesh/enemy_bot/DamageArea/HitscanPreview
@onready var attackrate: Timer = $Attackrate

@export var movement_speed: float = 4.0

var nearby_hostiles:Array = []
var curr_target:Node3D
var spawned_point:Vector3 #the point I will return to.
@export var enemy_tier:int = 1
@export var damage:float = 8
@onready var hostile_seeker: Area3D = $HostileSeeker
@onready var mesh: Node3D = $mesh
@onready var enemy_bot: Node3D = $mesh/enemy_bot

func _ready():
	enemy_bot.set_tier(enemy_tier)
	spawned_point = global_position
	# Get player from 'Player' group once at start
	health_label.text = str("Health: ", health, "/", max_health)

func _process(delta: float) -> void:
	if !is_on_floor():
		velocity += get_gravity() * delta
	if nearby_hostiles != []:
		curr_target = find_closest_target(hostile_seeker,"Ally")
	if is_instance_valid(curr_target):
		move_towards_target(curr_target.global_position,movement_speed)
		rotate_towards_target(curr_target.global_position,mesh,0.2)
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

func _on_damage_area_body_entered(body: Node3D) -> void:
	if "damage_func" in body:
		body.damage_func(damage)
		attack_collision.set_deferred("disabled", true)
		hitscan_preview.visible = false
		attackrate.start()




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
		death.rpc()
		

func heal_func(amount:float) -> void:
	health = min(health + amount, max_health)
	health_label.text = str("Health: ", health, "/", max_health)

@rpc("any_peer", "call_local")
func death() -> void:
	queue_free()

func _on_attackrate_timeout() -> void:
	attack_collision.disabled = false
	hitscan_preview.visible = true
