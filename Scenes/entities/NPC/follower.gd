extends CharacterBody3D


@onready var following:CharacterBody3D
var follower:CharacterBody3D #meant to get who is following me so we could be in a snake-like f0rmation.

@onready var character = $characterMesh
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var interact_target:Node3D

func _ready() -> void:
	following = get_tree().get_first_node_in_group("Player")
	following.signal_follow(self)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	if is_instance_valid(following.follower) and following.follower != self:
		following = following.follower
		following.signal_follow(self)
	# Handle jump.
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	character.look_at(following.global_position)
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("a", "d", "w", "s")
	var direction := (following.global_position - position).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	if Input.is_action_just_pressed("e") and is_instance_valid(interact_target):
		interact_target.interaction()

func signal_follow(body):
	follower = body
