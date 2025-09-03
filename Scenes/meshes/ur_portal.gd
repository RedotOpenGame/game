extends Area3D



func _on_body_entered(body: Node3D) -> void:
	if body.name == "PlayerActor":
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Levels/ur_gameplay.tscn")
