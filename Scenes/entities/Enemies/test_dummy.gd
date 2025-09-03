extends CharacterBody3D

@onready var damage: Label3D = $Damage


var total_damage:float = 0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func damage_func(amount) -> void:
	total_damage += amount
	damage.text = str("Damage: ", total_damage)

func death() -> void:
	queue_free()
