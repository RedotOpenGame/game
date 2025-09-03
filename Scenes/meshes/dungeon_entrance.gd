@tool
extends StaticBody3D
@onready var label_3d: Label3D = $Label3D

@export var path_to_scene:String = "res://Scenes/Levels/gameplay.tscn"
@export var label_text:String = "Dungeon entrance here."

func _ready() -> void:
	label_3d.text = label_text

func _on_touch_me_body_entered(body: Node3D) -> void:
	if body.name == "PlayerActor":
		get_tree().call_deferred("change_scene_to_file", path_to_scene)
