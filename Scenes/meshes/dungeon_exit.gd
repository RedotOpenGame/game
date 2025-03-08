extends StaticBody3D


func _on_touch_me_body_entered(body: Node3D) -> void:
	if body.name == "PlayerActor":
		get_tree().change_scene_to_file("res://Scenes/Levels/overworld.tscn")
