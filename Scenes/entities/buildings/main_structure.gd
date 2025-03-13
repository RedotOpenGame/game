extends CharacterBody3D

@onready var marker_3d: Marker3D = $Marker3D
@onready var make_ally: Button = $MakeAlly
@onready var scrap_counter: Label3D = $ScrapCounter


var track_body:CharacterBody3D #meant to track player mostly

var player_char = preload("res://Scenes/players/player_actor.tscn")
var ally_char = preload("res://Scenes/entities/NPC/follower_v_2.tscn")
@export var in_construction_mode:bool = false

func _ready() -> void:
	make_ally.visible = false
	scrap_counter.text = str("Scrap: ", Gameplay.scrap)

func placed_down() -> void:
	var scene = player_char.instantiate()
	scene.position = marker_3d.global_position
	add_sibling(scene)
	for i in get_tree().get_nodes_in_group("Ally"):
		i._ready()


func interaction() -> void:
	if is_instance_valid(track_body):
		Gameplay.scrap += track_body.remove_scrap()
		scrap_counter.text = str("Scrap: ", Gameplay.scrap)


func _on_interaction_area_body_entered(body: Node3D) -> void:
	if body.name == "PlayerActor":
		make_ally.visible = true
		track_body = body
		body.interact_target = self


func _on_interaction_area_body_exited(body: Node3D) -> void:
	if body.name == "PlayerActor":
		make_ally.visible = false
		track_body = null
		body.interact_target = self


func _on_make_ally_pressed() -> void:
	if Gameplay.scrap >= 3:
		Gameplay.scrap -= 3
		scrap_counter.text = str("Scrap: ", Gameplay.scrap)
		var scene = ally_char.instantiate()
		scene.position = marker_3d.global_position
		add_sibling(scene)
