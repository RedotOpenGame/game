extends CharacterBody3D

@onready var ui: CanvasLayer = $UI
@onready var scrap_counter: Label3D = $ScrapCounter
@onready var player_owner: Label3D = $PlayerOwner

var defence_turret:PackedScene = preload("res://Scenes/entities/buildings/defence_turret.tscn")
var mining_rig:PackedScene = preload("res://Scenes/entities/buildings/mining_rig.tscn")
var shoulder_gun:PackedScene = preload("res://Scenes/players/upgrades/shouldergun.tscn")

var owning_player:CharacterBody3D # tracking player
var player_name:String = "Pewweper"
#var show_name:bool = false

func _ready() -> void:
	ui.visible = false
	scrap_counter.text = str("Scrap: ", Gameplay.scrap)
	if owning_player.name != "PlayerActor":
		player_owner.visible = true
		player_owner.text = str("Placed by: ", player_name)

func _process(_delta: float) -> void:
	scrap_counter.text = str("Scrap: ", Gameplay.scrap)

@rpc("any_peer")
func interaction(body) -> void:
	if is_instance_valid(body) and !("get_object_id" in body):
		Gameplay.scrap += body.remove_scrap()
		scrap_counter.text = str("Scrap: ", Gameplay.scrap)

func _on_interaction_area_body_entered(body: Node3D) -> void:
	if "add_interactable" in body and body == owning_player:
		var peer_id = int(str(body.name))
		ui_thing.rpc_id(peer_id, true)
		body.add_interactable(self)

func _on_interaction_area_body_exited(body: Node3D) -> void:
	if "add_interactable" in body:
		var peer_id = int(str(body.name))
		ui_thing.rpc_id(peer_id, false)
		body.remove_interactable(self)

@rpc("any_peer", "call_local")
func ui_thing(boolean:bool) -> void:
	ui.visible = boolean

func check_balance(num:int) -> bool:
	if Gameplay.scrap >= num:
		Gameplay.scrap -= num
		scrap_counter.text = str("Scrap: ", Gameplay.scrap)
		return true
	return false

func _on_remove_pressed() -> void:
	fucking_die.rpc()
@rpc("any_peer", "call_local")
func fucking_die() -> void:
	owning_player.starting_building_placed = false
	queue_free()

func _on_make_combatant_pressed() -> void:
	if check_balance(2):
		owning_player.get_unit(1, 0)
func _on_make_collector_pressed() -> void:
	if check_balance(2):
		owning_player.get_unit(1, 2)
func _on_make_constructor_pressed() -> void:
	if check_balance(2):
		owning_player.get_unit(1, 1)

func _on_build_turret_pressed() -> void:
	IHateThis("defence_turret", "Defence turret", 3, 5)
func _on_build_mining_rig_pressed() -> void:
	IHateThis("mining_rig", "Mining rig", 5, 8)
func _on_add_shoulder_gun_pressed() -> void:
	if Gameplay.scrap >= 6:
		HangTheDeveloper()


func HangTheDeveloper() -> void:
	Gameplay.scrap -= 6
	owning_player.add_module.rpc("shouldergun")

func IHateThis(scene, string, work_req, price) -> void:
	owning_player.get_blueprint.rpc(scene, string, work_req, price)


func _on_build_mortar_pressed() -> void:
	IHateThis("mortar", "Mortar", 7, 20)
