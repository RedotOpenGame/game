extends Area3D

@onready var constructor_req: Label3D = $ConstructorReq
@onready var planned_building: Label3D = $PlannedBuilding
@onready var scrap_cost: Label3D = $ScrapCost
@onready var player_owner_label: Label3D = $PlayerOwner

const BUILDABLES:Dictionary = {
	"defence_turret":preload("res://Scenes/entities/buildings/defence_turret.tscn"),
	"mining_rig":preload("res://Scenes/entities/buildings/mining_rig.tscn")
}

var planned_bulding:String
var player_owner:CharacterBody3D
@export var unit_req:int = 3
var curr_unit:int = 0
@export var build_cost:int = 0 # the amount we can return
@export var build_name:String = "PLACEHOLDER"
var player_name:String = "Pewweper"
var show_name:bool = false

func _ready() -> void:
	planned_building.text = str("Planned building: ", build_name)
	constructor_req.text = str("Constructors in the area: ", curr_unit, "/", unit_req)
	scrap_cost.text = str("Scrap cost: ", Gameplay.scrap, "/", build_cost)
	if player_owner.name != "PlayerActor":
		player_owner_label.visible = true
		player_owner_label.text = str("Placed by: ", player_name)

func _process(_delta: float) -> void:
	scrap_cost.text = str("Scrap cost: ", Gameplay.scrap, "/", build_cost)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Ally") and "unit_type" in body:
		if body.unit_type == 1:
			curr_unit += 1
			constructor_req.text = str("Constructors in the area: ", curr_unit, "/", unit_req)
		if curr_unit >= unit_req and Gameplay.scrap >= build_cost:
			if planned_building:
				make_building.rpc()
			queue_free()
	if body.is_in_group("Player"):
		if body == player_owner:
			body.add_interactable(self)

@rpc("any_peer", "call_local")
func interaction(body) -> void:
	queue_free()

@rpc("any_peer", "call_local")
func place_itself():
	process_mode = Node.PROCESS_MODE_ALWAYS
	reparent(get_tree().get_first_node_in_group("AllyContainer"))

@rpc("any_peer", "call_local")
func make_building() -> void:
	Gameplay.scrap -= build_cost
	var scene = BUILDABLES[planned_bulding].instantiate()
	scene.show_name = player_owner_label.visible
	scene.player_name = player_name
	scene.position = global_position
	get_tree().get_first_node_in_group("AllyContainer").add_child(scene)

func _on_body_exited(body: Node3D) -> void:
	if "unit_type" in body:
		if body.unit_type == 1:
			curr_unit -= 1
			constructor_req.text = str("Constructors in the area: ", curr_unit, "/", unit_req)
	if body.is_in_group("Player"):
		if body == player_owner:
			body.remove_interactable(self)
