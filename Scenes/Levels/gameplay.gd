extends Node3D

@onready var main_structure: CharacterBody3D = $buildings/MainStructure
@onready var camera: Camera3D = $Freecam


func _process(delta: float) -> void:
	var target_plane_mouse = Plane(Vector3(0, 1, 0), position.y)
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var cursor_pos_on_plane = target_plane_mouse.intersects_ray(from, to)
	if cursor_pos_on_plane and !main_structure.process_mode == Node.PROCESS_MODE_ALWAYS:
		main_structure.position = cursor_pos_on_plane
	if Input.is_action_pressed("left_click") and !main_structure.process_mode == Node.PROCESS_MODE_ALWAYS:
		main_structure.process_mode = Node.PROCESS_MODE_ALWAYS
		main_structure.placed_down()
	if main_structure.process_mode == Node.PROCESS_MODE_ALWAYS:
		$CanvasLayer/Label.text = str("Scrap: ", Gameplay.scrap)

func _on_button_pressed() -> void:
	var loader = load("res://Scenes/entities/NPC/follower_v_2.tscn")
	var scene = loader.instantiate()
	scene.position = $Marker3D.position
	$Units.add_child(scene)
