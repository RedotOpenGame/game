extends CharacterBody3D

@onready var ui: CanvasLayer = $UI
@onready var scrap_counter: Label3D = $ScrapCounter
var defence_turret:PackedScene = preload("res://Scenes/entities/buildings/defence_turret.tscn")

var track_body:CharacterBody3D #meant to track player mostly

func _ready() -> void:
	ui.visible = false
	scrap_counter.text = str("Scrap: ", Gameplay.scrap)

func _process(delta: float) -> void:
	scrap_counter.text = str("Scrap: ", Gameplay.scrap)

func interaction() -> void:
	if is_instance_valid(track_body):
		Gameplay.scrap += track_body.remove_scrap()
		scrap_counter.text = str("Scrap: ", Gameplay.scrap)

func _on_interaction_area_body_entered(body: Node3D) -> void:
	if body.name == "PlayerActor":
		ui.visible = true
		track_body = body
		body.add_interactable(self)

func _on_interaction_area_body_exited(body: Node3D) -> void:
	if body.name == "PlayerActor":
		ui.visible = false
		track_body = null
		body.remove_interactable(self)

func check_balance(num:int) -> bool:
	if Gameplay.scrap >= num:
		Gameplay.scrap -= num
		scrap_counter.text = str("Scrap: ", Gameplay.scrap)
		return true
	return false

func _on_remove_pressed() -> void:
	track_body.starting_building_placed = false
	queue_free()


func _on_make_combatant_pressed() -> void:
	if check_balance(3):
		track_body.get_unit(1, 0)


func _on_make_collector_pressed() -> void:
	if check_balance(3):
		track_body.get_unit(1, 2)


func _on_make_constructor_pressed() -> void:
	if check_balance(3):
		track_body.get_unit(1, 1)
	


func _on_build_turret_pressed() -> void:
	track_body.get_blueprint(defence_turret, "Defence turret", 3, 5)
