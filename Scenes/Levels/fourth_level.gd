extends Node3D

@onready var control_point: Marker3D = $Objects/control_point
@onready var door_1: CyclopsBlock = $Blocks/Room1/Door/Moveable
@onready var door_2: CyclopsBlock = $Blocks/Room2/Door/Moveable
@onready var door_3: CyclopsBlock = $Blocks/Room3/Door/Moveable
@onready var door_4: CyclopsBlock = $Blocks/Room4/Door/Moveable
@onready var door_5: CyclopsBlock = $Blocks/Room5/Door/Moveable
@onready var door_6: CyclopsBlock = $Blocks/Room6/Door/Moveable


var door_1_height:float = 2.0

func _on_abyss_body_entered(body: Node3D) -> void:
	body.position = control_point.position


func _on_button_body_entered(body: Node3D) -> void:
	door_1_height += 1.0
	var tween = get_tree().create_tween()
	tween.tween_property($Blocks/Room1/Button/Orange, "position", Vector3(-0.15, 0,0), 0.5)
	tween.tween_property(door_1, "position", door_1.position + Vector3(0, 1.1, 0), 0.5)
	$Blocks/Room1/Button.set_deferred("monitoring", false)

func _on_button_2_body_entered(body: Node3D) -> void:
	door_1_height += 1.0
	var tween = get_tree().create_tween()
	tween.tween_property($Blocks/Room1/Button2/Orange, "position", Vector3(-0.15, 0,0), 0.5)
	tween.tween_property(door_1, "position", door_1.position + Vector3(0, 1, 0), 0.5)
	$Blocks/Room1/Button2.set_deferred("monitoring", false)
func _on_button_3_body_entered(body: Node3D) -> void:
	door_1_height += 1.0
	var tween = get_tree().create_tween()
	tween.tween_property($Blocks/Room1/Button3/Orange, "position", Vector3(-0.15, 0,0), 0.5)
	tween.tween_property(door_1, "position", door_1.position + Vector3(0, 1, 0), 0.5)
	$Blocks/Room1/Button3.set_deferred("monitoring", false)
func _on_button_4_body_entered(body: Node3D) -> void:
	door_1_height += 1.0
	var tween = get_tree().create_tween()
	tween.tween_property($Blocks/Room1/Button4/Orange, "position", Vector3(-0.15, 0,0), 0.5)
	tween.tween_property(door_1, "position", door_1.position + Vector3(0, 1, 0), 0.5)
	
	$Blocks/Room1/Button4.set_deferred("monitoring", false)


func _on_char_3d_block_dead() -> void:
	$Blocks/Room2/Destroyable.queue_free()
	$Blocks/Room2/FloorButton.monitoring = true


func _on_floor_button_body_entered(body: Node3D) -> void:
	var tween = get_tree().create_tween()
	tween.parallel().tween_property($Blocks/Room2/FloorButton/Yellow, "position", Vector3(-0.15, 0,0), 0.5)
	tween.parallel().tween_property(door_2, "position", door_2.position + Vector3(0, 4.1, 0), 1.2)


func _on_floor_button_room3_body_entered(body: Node3D) -> void:
	var tween = get_tree().create_tween()
	tween.parallel().tween_property($Blocks/Room3/FloorButton/Yellow, "position", Vector3(-0.15, 0,0), 0.5)
	tween.parallel().tween_property(door_3, "position", door_3.position + Vector3(0, 4.1, 0), 1.2)



func _on_throw_combatants_building_complete() -> void:
	$Blocks/Room3/FloorButton.visible = true
	$Blocks/Room3/FloorButton.monitoring = true

func _on_right_button_body_entered(body: Node3D) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(door_5, "position", door_5.position + Vector3(0, 1.1, 0), 0.5)

func _on_right_button_2_body_entered(body: Node3D) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(door_5, "position", door_5.position + Vector3(0, 1, 0), 0.5)


func _on_right_button_3_body_entered(body: Node3D) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(door_5, "position", door_5.position + Vector3(0, 1, 0), 0.5)


func _on_right_button_4_body_entered(body: Node3D) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(door_5, "position", door_5.position + Vector3(0, 1, 0), 0.5)


func _on_room_4_button_body_entered(body: Node3D) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($Blocks/Room4/Button/Orange, "position", Vector3(-0.15, 0,0), 0.5)
	tween.tween_property(door_4, "position", door_4.position + Vector3(0, 1.5, 0), 0.5)
	$Blocks/Room4/AnimationPlayer.pause()


func _on_room_4_button_2_body_entered(body: Node3D) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($Blocks/Room4/Button2/Orange, "position", Vector3(-0.15, 0,0), 0.5)
	tween.tween_property(door_4, "position", door_4.position + Vector3(0, 2.6, 0), 0.5)
	$Blocks/Room4/AnimationPlayer2.pause()


func _on_floor_button_button_pressed() -> void:
	if $Blocks/Room6/Timer.is_stopped():
		$Blocks/Room6/Timer.start()
	#print($Blocks/Room6/Platform1/FloorButton.is_pressed and $Blocks/Room6/Platform2/FloorButton.is_pressed and $Blocks/Room6/Platform3/FloorButton.is_pressed and $Blocks/Room6/Platform4/FloorButton.is_pressed)
	if $Blocks/Room6/Platform1/FloorButton.is_pressed and $Blocks/Room6/Platform2/FloorButton.is_pressed and $Blocks/Room6/Platform3/FloorButton.is_pressed and $Blocks/Room6/Platform4/FloorButton.is_pressed:
		var tween = get_tree().create_tween()
		tween.tween_property(door_6, "position", door_6.position + Vector3(0, 4.1, 0), 2)


func _on_timer_timeout() -> void:
	if !$Blocks/Room6/Platform1/FloorButton.is_pressed or !$Blocks/Room6/Platform2/FloorButton.is_pressed or !$Blocks/Room6/Platform3/FloorButton.is_pressed or !$Blocks/Room6/Platform4/FloorButton.is_pressed:
		$Blocks/Room6/Platform1/FloorButton.unpress()
		$Blocks/Room6/Platform2/FloorButton.unpress()
		$Blocks/Room6/Platform3/FloorButton.unpress()
		$Blocks/Room6/Platform4/FloorButton.unpress()
