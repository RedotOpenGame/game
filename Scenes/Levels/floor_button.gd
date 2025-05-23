extends Area3D

signal button_pressed
var is_pressed:bool = false

func _on_body_entered(body: Node3D) -> void:
	var tween = get_tree().create_tween()
	tween.parallel().tween_property($Yellow, "position", Vector3(-0.15, 0,0), 0.5)
	is_pressed = true
	button_pressed.emit()
	

func unpress() -> void:
	var tween = get_tree().create_tween()
	tween.parallel().tween_property($Yellow, "position", Vector3(0.2, 0,0), 0.5)
	is_pressed = false
func _on_body_exited(body: Node3D) -> void:
	var tween = get_tree().create_tween()
	tween.parallel().tween_property($Yellow, "position", Vector3(0.2, 0,0), 0.5)
