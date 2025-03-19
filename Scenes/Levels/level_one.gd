extends Node3D

@onready var control_point: Marker3D = $control_point
var constructor_in_the_area:int = 0

func _ready() -> void:
	$Objects/BridgeFix.visible = false
	$Objects/BridgeFix/CollisionShape3D.set_deferred("disabled", true)

func _on_abyss_body_entered(body: Node3D) -> void:
	body.position = control_point.position


func _on_constructor_area_body_entered(body: Node3D) -> void:
	if body.unit_type == 1:
		constructor_in_the_area += 1
	if constructor_in_the_area >= 2:
		$Objects/BridgeFix.visible = true
		$Objects/BridgeFix/CollisionShape3D.set_deferred("disabled", false)
		

func _on_constructor_area_body_exited(body: Node3D) -> void:
	if body.unit_type == 1:
		constructor_in_the_area -= 1
