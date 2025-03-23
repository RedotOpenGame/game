extends Node3D


func set_tier(num:int) -> void:
	if num == 1:
		$Wheel.mesh["surface_0/material"]["albedo_color"] = Color.RED
	elif num == 2:
		$Wheel.mesh["surface_0/material"]["albedo_color"] = Color.ORANGE_RED
