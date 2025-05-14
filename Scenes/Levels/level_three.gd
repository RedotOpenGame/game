extends Node3D
@onready var control_point: Marker3D = $Objects/control_point
@onready var red_wall: CyclopsBlock = $CyclopsBlocks_upgraded/RedWall
@onready var ladder: Node3D = $CyclopsBlocks_upgraded/ladder


func red_wall_about_to_fall() -> void: #this is a function called when one of the wall pillars die
	if red_wall.get_child_count() == 3:
		var tween = get_tree().create_tween()
		tween.tween_property(red_wall, "rotation", Vector3(-PI/2, 0, 0), 1)
		tween.tween_property(red_wall, "position", Vector3(-10, -1, -25), 1)

func build_staircase() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(ladder, "position", Vector3(0, 0, 0), 1.5)


func _on_abyss_body_entered(body: Node3D) -> void:
	body.position = control_point.position

func make_the_block_fall() -> void:
	$AnimationPlayer.play("BlockFall")
