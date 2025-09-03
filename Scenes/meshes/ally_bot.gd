extends Node3D

func set_type(type:int) -> void:
	match type:
		0:
			$Wheel.mesh["surface_0/material"]["albedo_color"] = Color("ffa9ff")
		1:
			$Wheel.mesh["surface_0/material"]["albedo_color"] = Color("00ffff")
		2:
			$Wheel.mesh["surface_0/material"]["albedo_color"] = Color("00ffa0")
