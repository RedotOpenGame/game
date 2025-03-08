extends CharacterBody3D

@onready var health_label: Label3D = $HealthLabel



@export var row_spacing: float = 1.5
@export var column_spacing: float = 1.5
@export var movement_speed: float = 4.0
var unit_index: int = 0  # Assign unique index to each unit

var max_health:float = 40
var health:float = max_health

var _leader: Node3D

func _ready():
	# Get player from 'Player' group once at start
	health_label.text = str("Health: ", health, "/", max_health)
	_leader = get_tree().get_first_node_in_group("Player")
	if !_leader:
		#push_error("No player found in 'Player' group")
		return
	_leader.signal_follow(self)

func _process(delta):
	if not _leader:
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Calculate row and column position in formation
	var r := int((sqrt(8 * unit_index + 1) - 1) / 2)
	var c := unit_index - (r * (r + 1)) / 2
	
	# Calculate horizontal offset for symmetrical placement
	var horizontal_offset := (c - r / 2.0) * column_spacing
	
	# Calculate target position relative to leader
	var preffered_position = _leader.global_position + Vector3(horizontal_offset, 0, (r + 1) * row_spacing).rotated(Vector3(0, 1, 0), _leader.camera_control.global_rotation.y)
	var direction = (preffered_position - global_position).normalized()
	
	if global_position.distance_to(preffered_position) < movement_speed / 32:
		global_position = preffered_position
		velocity = Vector3(0, 0, 0)
	else:
		velocity = direction * movement_speed
		#print(global_position.distance_to(preffered_position))
	#var target_position := _leader.global_transform.origin \
		#+ (_leader.global_transform.basis.z * (r + 1) * row_spacing \
		#+ _leader.global_transform.basis.x * horizontal_offset).rotated(Vector3(0, 1, 0), _leader.camera_control.global_rotation.y)
	#
	## Smoothly move towards target position
	#global_transform.origin = global_transform.origin.move_toward(
		#target_position,
		#movement_speed * delta
	#)
	move_and_slide()


func damage_func(amount:float) -> void:
	health -= amount
	health_label.text = str("Health: ", health, "/", max_health)
	if health <= 0:
		death()

func throw() -> void:
	velocity += Vector3(20, 20, 0).rotated(Vector3(0, 1, 0), _leader.camera_control.global_rotation.y) #NOT WORKING RN
	print("throwing")

func death() -> void:
	_leader.ally_died(self)
	queue_free()
