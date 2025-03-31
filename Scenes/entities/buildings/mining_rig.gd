extends GeneralEntity

@onready var health_label: Label3D = $HealthLabel

func _ready() -> void:
	health_label.text = str("Health: ", health, "/", max_health)

func get_resource() -> void:
	Gameplay.scrap += 2

func damage_func(amount:float) -> void:
	health -= amount
	health_label.text = str("Health: ", health, "/", max_health)
	if health <= 0:
		death()

func heal_func(amount:float) -> void:
	health = min(health + amount, max_health)
	health_label.text = str("Health: ", health, "/", max_health)
