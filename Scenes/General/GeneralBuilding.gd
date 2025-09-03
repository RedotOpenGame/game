extends GeneralEntity
class_name GeneralBuilding

var resource_pile = preload("res://Scenes/misc/resource_pile.tscn")
@export var dropped_scrap:int = 0

var player_id:int = 0
var player_name:String = "Pewweper"
var show_name:bool = false

func death() -> void:
	var scene = resource_pile.instantiate()
	scene.position = global_position
	scene.scrap = dropped_scrap
	add_sibling(scene)
	queue_free()

@rpc("any_peer", "call_local")
func demolish() -> void:
	death()
