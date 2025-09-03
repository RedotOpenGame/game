extends Node3D

@onready var control_point: Marker3D = $Objects/control_point
@onready var block_41: CyclopsBlock = $CyclopsBlocks_upgraded/Block_41
@onready var block_holder: CharacterBody3D = $CyclopsBlocks_upgraded/Block_41/BlockHolder


func _on_abyss_body_entered(body: Node3D) -> void:
	body.position = control_point.position


func _on_throw_combatants_building_complete() -> void:
	$AnimationPlayer.play("BuildBridge")


func _on_throw_combatants_2_building_complete() -> void:
	$AnimationPlayer.play("BuildCylinder")


func _on_block_holder_block_damaged() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(block_41, "position", Vector3(-17, 12, 49 - 5 * ((block_holder.max_health - block_holder.health) / block_holder.max_health)), 0.5)


func _on_block_holder_block_dead() -> void:
	$AnimationPlayer.play("block_fall")


func _on_button_body_entered(body: Node3D) -> void:
	$CyclopsBlocks_upgraded/Platforms/MovingSticks/AnimationPlayer.play("open_close")


func _on_floor_button_body_entered(body: Node3D) -> void:
	var tween = get_tree().create_tween()
	tween.parallel().tween_property($CyclopsBlocks_upgraded/Door/FloorButton/Yellow, "position", Vector3(-0.15, 0,0), 0.5)
	tween.parallel().tween_property($CyclopsBlocks_upgraded/Door/Movable, "position", Vector3(-76, 14, 61), 2)

func _on_floor_button_body_exited(body: Node3D) -> void:
	var tween = get_tree().create_tween()
	tween.parallel().tween_property($CyclopsBlocks_upgraded/Door/FloorButton/Yellow, "position", Vector3(0.2, 0,0), 0.5)
	if $CyclopsBlocks_upgraded/Door/FloorButton2.get_overlapping_bodies() == [] and $CyclopsBlocks_upgraded/Door/FloorButton.get_overlapping_bodies() == []:
		tween.parallel().tween_property($CyclopsBlocks_upgraded/Door/Movable, "position", Vector3(-76, 9, 61), 2)


func _on_floor_button_2_body_entered(body: Node3D) -> void:
	var tween = get_tree().create_tween()
	tween.parallel().tween_property($CyclopsBlocks_upgraded/Door/FloorButton2/Yellow, "position", Vector3(-0.15, 0,0), 0.5)
	tween.parallel().tween_property($CyclopsBlocks_upgraded/Door/Movable, "position", Vector3(-76, 14, 61), 2)


func _on_floor_button_2_body_exited(body: Node3D) -> void:
	if $CyclopsBlocks_upgraded/Door/FloorButton2.get_overlapping_bodies() == []:
		var tween = get_tree().create_tween()
		tween.parallel().tween_property($CyclopsBlocks_upgraded/Door/FloorButton2/Yellow, "position", Vector3(0.2, 0,0), 0.5)
		if $CyclopsBlocks_upgraded/Door/FloorButton.get_overlapping_bodies() == []:
			tween.parallel().tween_property($CyclopsBlocks_upgraded/Door/Movable, "position", Vector3(-76, 9, 61), 2)
