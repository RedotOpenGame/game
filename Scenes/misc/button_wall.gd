extends Area3D


func _on_body_entered(body: Node3D) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($Orange, "position", Vector3(-0.15, 0,0), 0.5)
	set_deferred("monitoring", false)
