extends Area3D

@onready var constructor_req: Label3D = $ConstructorReq
@onready var planned_building: Label3D = $PlannedBuilding
@onready var scrap_cost: Label3D = $ScrapCost
signal building_complete


@export var unit_req:int = 3
var curr_unit:int = 0
@export var build_cost:int = 0 # the amount we can return
@export var build_name:String = "PLACEHOLDER"

func _ready() -> void:
	if build_cost == 0 and unit_req == 0:
		print("Blueprint has 0 unit requirement and 0 scrap requirement. Guess I'm building myself lmao.")
		building_complete.emit()
		queue_free()
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
			building_complete.emit()
			queue_free()
			

func _on_body_exited(body: Node3D) -> void:
	if body.unit_type == 1:
		curr_unit -= 1
		constructor_req.text = str("Constructors in the area: ", curr_unit, "/", unit_req)
