extends Area3D



func _on_body_entered(body: Node3D) -> void:
	if "damage_func" in body:
		body.damage_func(8)
