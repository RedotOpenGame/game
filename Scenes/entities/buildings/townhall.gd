extends CharacterBody3D

var max_health:float = 1500
var health:float = max_health
@onready var health_label: Label3D = $HealthLabel
var i_died:bool = false

func _ready() -> void:
	health_label.text = str("Health: ", health, " / ", max_health)


func damage_func(amount:float) -> void:
	health -= amount
	health_label.text = str("Health: ", health, " / ", max_health)
	if health <= 0:
		death()

func heal_func(amount:float) -> void:
	health = min(health + amount, max_health)
	health_label.text = str("Health: ", health, "/", max_health)

func death() -> void:
	if !i_died:
		$LosingUI.visible = true
		$LosingUI/VideoStreamPlayer.play()
		i_died = true
	#queue_free()


func _on_button_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/overworld.tscn")
