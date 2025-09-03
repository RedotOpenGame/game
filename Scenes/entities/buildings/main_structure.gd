extends CharacterBody3D

@onready var marker_3d: Marker3D = $Marker3D
@onready var ui: CanvasLayer = $UI
@onready var scrap_counter: Label3D = $ScrapCounter


var track_body:CharacterBody3D #meant to track player mostly

var player_char = preload("res://Scenes/players/player_actor.tscn")
var ally_char = preload("res://Scenes/entities/NPC/follower_v_2.tscn")
@export var in_construction_mode:bool = false

func _ready() -> void:
	ui.visible = false
	scrap_counter.text = str("Scrap: ", Gameplay.scrap)

func _process(_delta: float) -> void:
	scrap_counter.text = str("Scrap: ", Gameplay.scrap)

func placed_down() -> void:
	var scene = player_char.instantiate()
	scene.position = marker_3d.global_position
	add_sibling(scene)
	for i in get_tree().get_nodes_in_group("Ally"):
		i._ready()

@rpc("any_peer", "call_local")
func interaction(body) -> void:
	if is_instance_valid(body) and !("get_object_id" in body):
		var value = body.curr_scrap
		body.remove_scrap.rpc()
		Gameplay.plus_scrap.rpc(value)
		#print(value, " scrap added by: ", body.name)
		scrap_counter.text = str("Scrap: ", Gameplay.scrap)


func _on_interaction_area_body_entered(body: Node3D) -> void:
	if "add_interactable" in body:
		ui.visible = true
		body.add_interactable(self)
	if body.is_in_group("Unit"):
		Gameplay.scrap += body.resources
		scrap_counter.text = str("Scrap: ", Gameplay.scrap)
		body.resources = 0


func _on_interaction_area_body_exited(body: Node3D) -> void:
	if "add_interactable" in body:
		ui.visible = false
		body.remove_interactable(self)


func _on_make_ally_pressed() -> void:
	if Gameplay.scrap >= 3:
		Gameplay.scrap -= 3
		scrap_counter.text = str("Scrap: ", Gameplay.scrap)
		var scene = ally_char.instantiate()
		scene.position = marker_3d.global_position
		add_sibling(scene)


func _on_upgrade_carry_pressed() -> void:
	if Gameplay.scrap >= 4:
		Gameplay.scrap -= 4
		scrap_counter.text = str("Scrap: ", Gameplay.scrap)
		track_body.max_scrap += 2
		$UI/UpgradeCarry.disabled = true


func _on_increase_speed_pressed() -> void:
	if Gameplay.scrap >= 6:
		Gameplay.scrap -= 6
		scrap_counter.text = str("Scrap: ", Gameplay.scrap)
		track_body.SPEED += 1.5
		$UI/IncreaseSpeed.disabled = true

func demolish() -> void:
	print("You really thought you could do that? LMAO")
