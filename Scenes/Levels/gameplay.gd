extends Node3D


func _on_button_pressed() -> void:
	var loader = load("res://Scenes/entities/NPC/follower_v_2.tscn")
	var scene = loader.instantiate()
	scene.position = $Marker3D.position
	$Units.add_child(scene)
