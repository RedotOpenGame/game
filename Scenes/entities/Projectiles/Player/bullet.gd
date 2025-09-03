extends Area3D

@export var speed:float = 0.3
var direction:Vector3 

func _process(delta: float) -> void:
	position += speed * direction


func _on_cleanup_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node3D) -> void:
	if "damage_func" in body:
		body.damage_func(8)
	queue_free()
