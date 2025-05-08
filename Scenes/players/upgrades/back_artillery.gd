extends Node3D

var using_second_barrel:bool = false
@onready var firerate: Timer = $Firerate

@onready var barrel_1: Marker3D = $Barrel1
@onready var barrel_2: Marker3D = $Barrel2

const bomb_scene = preload("res://Scenes/entities/Projectiles/Player/bomb.tscn")
var damage:int = 15
var can_fire:bool = true


@rpc("any_peer", "call_local")
func shoot(target_point) -> void:
	if can_fire:
		can_fire = false
		firerate.start()
		var scene = bomb_scene.instantiate()
		if !using_second_barrel:
			scene.position = barrel_1.global_position
		else:
			scene.position = barrel_2.global_position
		using_second_barrel = !using_second_barrel
		scene.damage = damage
		scene.rotation = global_rotation
		
		get_tree().current_scene.add_child(scene)
		scene.initialize(target_point)

func _on_firerate_timeout() -> void:
	can_fire = true
