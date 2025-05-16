extends CharacterBody3D

signal block_dead
signal block_damaged
@onready var health_label: Label3D = $HealthLabel

@export var max_health = 200
@onready var health = max_health
func _ready() -> void:
	health_label.text = str("Health: ", health)

func damage_func(amount:float) -> void:
	block_damaged.emit()
	health -= amount
	health_label.text = str("Health: ", health)
	if health <= 0:
		death()

func death():
	block_dead.emit()
	queue_free()
