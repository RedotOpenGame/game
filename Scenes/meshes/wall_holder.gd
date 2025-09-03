extends CharacterBody3D

@onready var health_label: Label3D = $HealthLabel
var health = 60

func _ready() -> void:
	health_label.text = str("Health: ", health)

func damage_func(amount:float) -> void:

	health -= amount
	health_label.text = str("Health: ", health)
	if health <= 0:
		death()

func death():
	get_parent().get_parent().get_parent().red_wall_about_to_fall()
	queue_free()
