extends Node3D

var player_char = preload("res://Scenes/players/player_actor.tscn")

func _ready() -> void:
	for i in MultiplayerHelper.Players:
		var player = player_char.instantiate()
		player.position = $PlayerSpawnpoint.position + Vector3(randi_range(-5, 5), 0, randi_range(-5, 5))
		$PlayerSpawnpoint.add_child(player)
