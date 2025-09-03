extends MeshInstance3D

func set_type(type:int) -> void:
	match type:
		0:
			mesh["material"]["albedo_color"] = Color("ffa9ff")
		1:
			mesh["material"]["albedo_color"] = Color("00ffff")
		2:
			mesh["material"]["albedo_color"] = Color("00ffa0")
