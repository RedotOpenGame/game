extends CharacterBody3D

@onready var marker_3d: Marker3D = $Marker3D


var player_char = preload("res://Scenes/players/player_actor.tscn")
@export var in_construction_mode:bool = false

func placed_down() -> void:
	var scene = player_char.instantiate()
	scene.position = marker_3d.global_position
	add_sibling(scene)
	for i in get_tree().get_nodes_in_group("Ally"):
		i._ready()
