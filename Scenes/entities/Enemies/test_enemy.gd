extends CharacterBody3D

@onready var health_label: Label3D = $HealthLabel
@onready var attack_collision: CollisionShape3D = $DamageArea/AttackCollision
@onready var hitscan_preview: MeshInstance3D = $DamageArea/HitscanPreview
@onready var attackrate: Timer = $Attackrate

@export var movement_speed: float = 4.0

var nearby_hostiles:Array = []
var curr_target:Node3D
@export var max_health:float = 40
@onready var health:float = max_health

func _ready():
	# Get player from 'Player' group once at start
	health_label.text = str("Health: ", health, "/", max_health)

func _process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if !is_instance_valid(curr_target):
		velocity = Vector3(0, 0, 0)
		if nearby_hostiles != []:
			curr_target = find_closest_target()
	else:
		look_at(curr_target.global_position)
		var preffered_position = curr_target.global_position
		var direction = (preffered_position - global_position).normalized()
		velocity = direction * movement_speed
	
	move_and_slide()

func _on_damage_area_body_entered(body: Node3D) -> void:
	if "damage_func" in body:
		body.damage_func(8)
		attack_collision.set_deferred("disabled", true)
		hitscan_preview.visible = false
		attackrate.start()


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
	attack_collision.disabled = false
	hitscan_preview.visible = true
