extends Node3D

@onready var control_point: Marker3D = $Objects/control_point

func _on_throw_combatants_building_complete() -> void:
	$Blocks/AnimationPlayer.play("make_ramp")


func _on_abyss_body_entered(body: Node3D) -> void:
	body.position = control_point.position


func _on_char_3d_block_dead() -> void:
	$Blocks/Maze/BlockingBlocks/Block_0.queue_free()


func _on_char_3d_2_block_dead() -> void:
	$Blocks/Maze/BlockingBlocks/Block_1.queue_free()


func _on_throw_combatants_2_building_complete() -> void:
	var tween = get_tree().create_tween()
	var increment = 0
	print($Blocks/Endgame/Stairs.get_child_count())
	for i in $Blocks/Endgame/Stairs.get_children():
		increment += 0.01
		tween.tween_property(i, "position", i.position + Vector3(0, 17, 0), 0.8 - increment)
