extends CharacterBody3D

var max_health:float = 500
var health:float = max_health
@onready var health_label: Label3D = $HealthLabel

func _ready() -> void:
	health_label.text = str("Health: ", health, " / ", max_health)


func damage_func(amount:float) -> void:
	health -= amount
	health_label.text = str("Health: ", health, " / ", max_health)
	if health <= 0:
		death()
	

func death() -> void:
	queue_free()
