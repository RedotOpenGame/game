extends Area3D

@onready var constructor_req: Label3D = $ConstructorReq
@onready var planned_building: Label3D = $PlannedBuilding
@onready var scrap_cost: Label3D = $ScrapCost


var planned_bulding:PackedScene
var unit_req:int = 3
var curr_unit:int = 0
var build_cost:int = 0 # the amount we can return
var build_name:String = "PLACEHOLDER"

func _ready() -> void:
	planned_building.text = str("Planned building: ", build_name)
	constructor_req.text = str("Constructors in the area: ", curr_unit, "/", unit_req)
	scrap_cost.text = str("Scrap cost: ", Gameplay.scrap, "/", build_cost)

func _process(delta: float) -> void:
	scrap_cost.text = str("Scrap cost: ", Gameplay.scrap, "/", build_cost)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Ally"):
		if body.unit_type == 1:
			curr_unit += 1
			constructor_req.text = str("Constructors in the area: ", curr_unit, "/", unit_req)
		if curr_unit >= unit_req and Gameplay.scrap >= build_cost:
			Gameplay.scrap -= build_cost
			var scene = planned_bulding.instantiate()
			scene.position = global_position
			get_tree().get_first_node_in_group("AllyContainer").add_child(scene)
			queue_free()

func _on_body_exited(body: Node3D) -> void:
	if body.unit_type == 1:
		curr_unit -= 1
		constructor_req.text = str("Constructors in the area: ", curr_unit, "/", unit_req)
