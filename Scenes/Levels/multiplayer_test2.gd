extends Node3D

var player_char = preload("res://Scenes/players/player_actor.tscn")

var enemy_char = preload("res://Scenes/entities/Enemies/test_enemy.tscn")

func _ready() -> void:
	for i in MultiplayerHelper.Players:
		var player = player_char.instantiate()
		player.name = str(MultiplayerHelper.Players[i].id)
		player.position = $PlayerSpawnpoint.position + Vector3(randi_range(-5, 5), 0, randi_range(-5, 5))
		$PlayerSpawnpoint.add_child(player)
		Gameplay.scrap = 666


func _on_multiplayer_spawner_despawned(node: Node) -> void:
	pass # Replace with function body.


func _on_spawn_enemy_pressed() -> void:
	spawn_enemy.rpc()

@rpc("any_peer", "call_local")
func spawn_enemy() -> void:
	var rng = RandomNumberGenerator.new()
	var enemy = enemy_char.instantiate()
	enemy.position = $EnemySpawnpoint.position + Vector3(rng.randf_range(-5, 5), 0, rng.randf_range(-5, 5))
	$EnemySpawnpoint.add_child(enemy)
	$SpawnEnemy.release_focus()
