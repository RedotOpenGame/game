extends Area3D

var damage:float = 0.0



func _on_body_entered(body: Node3D) -> void:
		if body.has_method("damage_func"):
			body.damage_func(damage)


func _on_cleanup_timeout() -> void:
	queue_free()
