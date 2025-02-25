extends CharacterBody3D

@export var row_spacing: float = 1.5
@export var column_spacing: float = 1.5
@export var movement_speed: float = 4.0
var unit_index: int = 0  # Assign unique index to each unit

var _leader: Node3D

func _ready():
	# Get player from 'Player' group once at start
	_leader = get_tree().get_first_node_in_group("Player")
	if not _leader:
		push_error("No player found in 'Player' group")
	_leader.signal_follow(self)

func _process(delta):
	if not _leader:
		return
	
	# Calculate row and column position in formation
	var r := int((sqrt(8 * unit_index + 1) - 1) / 2)
	var c := unit_index - (r * (r + 1)) / 2
	
	# Calculate horizontal offset for symmetrical placement
	var horizontal_offset := (c - r / 2.0) * column_spacing
	
	# Calculate target position relative to leader
	var target_position := _leader.global_transform.origin \
		+ _leader.global_transform.basis.z * (r + 1) * row_spacing \
		+ _leader.global_transform.basis.x * horizontal_offset
	
	# Smoothly move towards target position
	global_transform.origin = global_transform.origin.move_toward(
		target_position,
		movement_speed * delta
	)
