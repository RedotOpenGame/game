extends Node3D

@onready var control_point: Marker3D = $Objects/control_point

func _on_abyss_body_entered(body: Node3D) -> void:
	body.position = control_point.position


func _on_throw_combatants_building_complete() -> void:
	print("building complete")
