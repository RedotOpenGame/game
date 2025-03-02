extends CharacterBody3D

@onready var marker_3d: Marker3D = $Marker3D

var track_body:CharacterBody3D #meant to track player mostly

var player_char = preload("res://Scenes/players/player_actor.tscn")
@export var in_construction_mode:bool = false

func placed_down() -> void:
	var scene = player_char.instantiate()
	scene.position = marker_3d.global_position
	add_sibling(scene)
	for i in get_tree().get_nodes_in_group("Ally"):
		i._ready()


func interaction() -> void:
	if is_instance_valid(track_body):
		Gameplay.scrap += track_body.remove_scrap()


func _on_interaction_area_body_entered(body: Node3D) -> void:
	if body.name == "PlayerActor":
		track_body = body
		body.interact_target = self


func _on_interaction_area_body_exited(body: Node3D) -> void:
	if body.name == "PlayerActor":
		track_body = null
		body.interact_target = self
