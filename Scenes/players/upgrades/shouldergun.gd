extends Node3D
@onready var marker_3d: Marker3D = $Marker3D
@onready var firerate: Timer = $Firerate

const bullet_scene = preload("res://Scenes/entities/Projectiles/Player/bullet.tscn")
var damage:int = 5
var can_fire:bool = true


func shoot(target_point) -> void:
	if can_fire:
		can_fire = false
		firerate.start()
		var direction = (target_point - marker_3d.global_position).normalized()
		var scene = bullet_scene.instantiate()
		scene.damage = damage
		scene.position = marker_3d.global_position
		scene.rotation = global_rotation
		scene.penetrating = true
		scene.direction = direction
		get_tree().current_scene.add_child(scene)


func _on_firerate_timeout() -> void:
	can_fire = true
