extends CharacterBody3D
class_name GeneralEntity

@export var max_health:float = 100.0
@onready var health:float = max_health

func damage_func(amount:float) -> void:
	health -= amount
	if health <= 0:
		death()

func heal_func(amount:float) -> void:
	health = min(health + amount, max_health)

func death():
	queue_free()
