extends Node

var scrap:int = 0
var paused:bool = false

@rpc("any_peer", "call_local")
func plus_scrap(amount) -> void:
	scrap += amount
