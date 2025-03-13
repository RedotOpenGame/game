extends CharacterBody3D

@export var scrap:int = 20
var track_body:CharacterBody3D #meant to track player mostly

func interaction() -> void:
	if is_instance_valid(track_body):
		scrap -= track_body.get_scrap(1)
		if scrap <= 0:
			queue_free()

func _on_interaction_area_body_entered(body: Node3D) -> void:
	if body.name == "PlayerActor":
		track_body = body
		body.interact_target = self


func _on_interaction_area_body_exited(body: Node3D) -> void:
	if body.name == "PlayerActor":
		track_body = null
		body.interact_target = null
