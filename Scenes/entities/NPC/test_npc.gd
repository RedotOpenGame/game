extends CharacterBody3D

@onready var label_3d = $Label3D
var interaction_scene = preload("res://Scenes/misc/text_interaction.tscn")

func _ready() -> void:
	label_3d.visible = false

func interaction() -> void:
	print("interaction")
	var scene = interaction_scene.instantiate()
	get_tree().root.add_child(scene)

func _on_interactable_body_entered(body: Node3D) -> void:
	if body.name == "PlayerActor":
		label_3d.visible = true
		body.interact_target = self


func _on_interactable_body_exited(body: Node3D) -> void:
	if body.name == "PlayerActor":
		label_3d.visible = false
		body.interact_target = null
