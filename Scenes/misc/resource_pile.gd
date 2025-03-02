extends CharacterBody3D


var track_body:CharacterBody3D #meant to track player mostly

func interaction() -> void:
	if is_instance_valid(track_body):
		track_body.get_scrap(1)

func _on_interaction_area_body_entered(body: Node3D) -> void:
	if body.name == "PlayerActor":
		track_body = body
		body.interact_target = self


func _on_interaction_area_body_exited(body: Node3D) -> void:
	if body.name == "PlayerActor":
		track_body = null
		body.interact_target = null
