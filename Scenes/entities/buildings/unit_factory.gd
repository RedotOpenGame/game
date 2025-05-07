extends GeneralBuilding

enum unit_types{COMBAT,BUILDER,AGRI}
var current_type = unit_types.COMBAT
const unit_scene:PackedScene = preload("res://Scenes/entities/NPC/unit.tscn")

@onready var unit_production_label: Label3D = $UnitProductionLabel
@onready var unit_spawn: Marker3D = $UnitSpawn
@onready var health_label: Label3D = $HealthLabel


func _ready():
	health_label.text = str("Health: ", health, "/", max_health)
	$PlayerOwner.visible = show_name
	$PlayerOwner.text = str("Placed by: ", player_name)

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			change_unit_type.rpc()

@rpc("any_peer", "call_local")
func change_unit_type() -> void:
	if current_type == unit_types.COMBAT:
		current_type = unit_types.BUILDER
		unit_production_label.text = str("Current unit production: Constructor")
	elif current_type == unit_types.BUILDER:
		current_type = unit_types.AGRI
		unit_production_label.text = str("Current unit production: Collector")
	else:
		current_type = unit_types.COMBAT
		unit_production_label.text = str("Current unit production: Combatant")
func _on_area_3d_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CursorShape.CURSOR_POINTING_HAND)


func _on_area_3d_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CursorShape.CURSOR_ARROW)

func get_resource() -> void:
	_on_unit_spawn_2_timeout()

func _on_unit_spawn_2_timeout() -> void:
	var instance = unit_scene.instantiate()
	if !show_name:
		instance._leader = get_tree().get_first_node_in_group("Player")
	else:
		var players = get_tree().get_nodes_in_group("Player")
		var found_player
		for player in players:
			if player.name == str(player_id):
				found_player = player
		
		instance._leader = found_player
		
	instance.player_name = player_name
	instance.position = global_position
	instance.throw_target = unit_spawn.global_position
	instance.unit_type = current_type
	add_sibling(instance)
	instance.get_node("characterMesh").rotation.y = rotation.y
	
