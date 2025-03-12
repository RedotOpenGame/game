extends CharacterBody3D

var max_health:float = 500
var health:float = max_health
@onready var progressbar_health: ProgressBar = $ProgressbarHealth

func _ready() -> void:
	progressbar_health.max_value = max_health
	progressbar_health.value = health



func damage_func(amount:float) -> void:
	health -= amount
	progressbar_health.value = health
	if health <= 0:
		death()
	

func death() -> void:
	queue_free()
