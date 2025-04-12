extends CharacterBody3D

@export var scrap:int = 20
var track_bodies:Array #meant to track player mostly

@rpc("call_local", "any_peer")
func interaction(body) -> void:
	if "get_object_id" in body:
		return
	
	scrap -= body.get_scrap(1)
	#print("scrap received for: ", body.name)
	if scrap <= 0:
		fucking_die.rpc()

@rpc("call_local", "any_peer")
func fucking_die() -> void:
	queue_free()

func _on_interaction_area_body_entered(body: Node3D) -> void:
	if "add_interactable" in body:
		body.add_interactable(self)


func _on_interaction_area_body_exited(body: Node3D) -> void:
	if "add_interactable" in body:
		body.remove_interactable(self)
