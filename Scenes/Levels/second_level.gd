extends Node3D

const mining_rig:PackedScene = preload("res://Scenes/entities/buildings/alternative_mining_rig.tscn")

@onready var control_point: Marker3D = $Objects/control_point
@onready var anim: AnimationPlayer = $Blocks/BuildableShit/AnimationPlayer
@onready var mining_rig_spawn: Marker3D = $Objects/MiningRigSpawn
@onready var anim2: AnimationPlayer = $AnimationPlayer

var bridge_holders:int = 2
var bridge_holders2:int = 2

func _on_abyss_body_entered(body: Node3D) -> void:
	body.position = control_point.position


func _on_throw_combatants_building_complete() -> void:
	anim.play("make_bridge")


func _on_throw_combatants_2_building_complete() -> void:
	var scene = mining_rig.instantiate()
	scene.position = mining_rig_spawn.position
	add_child(scene)


func _on_throw_combatants_3_building_complete() -> void:
	anim.play("make_bridge2")



func _on_bridge_holder_1_block_dead() -> void:
	$Blocks/Island3/Destroyable1.queue_free()
	bridge_holders -= 1
	if bridge_holders == 0:
		anim2.play("fall_bridge")


func _on_bridge_holder_2_block_dead() -> void:
	$Blocks/Island3/Destroyable2.queue_free()
	bridge_holders -= 1
	if bridge_holders == 0:
		anim2.play("fall_bridge")


func _on_bridge_holder_3_block_dead() -> void:
	$Blocks/Island4/Destroyable3.queue_free()
	bridge_holders2 -= 1
	if bridge_holders2 == 0:
		anim2.play("fall_bridge2")


func _on_bridge_holder_4_block_dead() -> void:
	$Blocks/Island4/Destroyable4.queue_free()
	bridge_holders2 -= 1
	if bridge_holders2 == 0:
		anim2.play("fall_bridge2")


func _on_floor_button_2_body_entered(body: Node3D) -> void:
	var tween = get_tree().create_tween()
	tween.parallel().tween_property($Blocks/Island5/FloorButton2/Yellow, "position", Vector3(-0.15, 0,0), 0.5)
	tween.parallel().tween_property($Blocks/Island5/Door, "position", Vector3(-181, 8, 151), 2)



func _on_floor_button_2_body_exited(body: Node3D) -> void:
	if $Blocks/Island5/FloorButton2.get_overlapping_bodies() == []:
		var tween = get_tree().create_tween()
		tween.parallel().tween_property($Blocks/Island5/FloorButton2/Yellow, "position", Vector3(0.2, 0,0), 0.5)
		if $Blocks/Island5/FloorButton.get_overlapping_bodies() == []:
			tween.parallel().tween_property($Blocks/Island5/Door, "position", Vector3(-181, 4, 151), 2)


func _on_floor_button_body_entered(body: Node3D) -> void:
	var tween = get_tree().create_tween()
	tween.parallel().tween_property($Blocks/Island5/FloorButton/Yellow, "position", Vector3(-0.15, 0,0), 0.5)
	tween.parallel().tween_property($Blocks/Island5/Door, "position", Vector3(-181, 8, 151), 2)



func _on_floor_button_body_exited(body: Node3D) -> void:
	if $Blocks/Island5/FloorButton.get_overlapping_bodies() == []:
		var tween = get_tree().create_tween()
		tween.parallel().tween_property($Blocks/Island5/FloorButton/Yellow, "position", Vector3(0.2, 0,0), 0.5)
		if $Blocks/Island5/FloorButton2.get_overlapping_bodies() == []:
			tween.parallel().tween_property($Blocks/Island5/Door, "position", Vector3(-181, 4, 151), 2)
