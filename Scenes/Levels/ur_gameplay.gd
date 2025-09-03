extends Node3D

@onready var timer: Label = $Timer
@onready var enemy_spawnpoint: Marker3D = $EnemySpawnpoint
@onready var enemies: Node3D = $Enemies
@onready var spawner: Timer = $Spawner
var boss_on_field:Node3D

var enemy_list:Dictionary = {
	#"Example":preload("path/to/enemy/scene.tscn"),
	"Test_Boss":{"scene":preload("res://Scenes/entities/Enemies/test_boss.tscn"), "weight":4.5},
	"Shooter":{"scene":preload("res://Scenes/entities/Enemies/shooting_enemy.tscn"), "weight":3},
	"Test_Enemy":{"scene":preload("res://Scenes/entities/Enemies/test_enemy.tscn"), "weight":1},
}
const max_diff_scale:float = 5.0
var diff_scale:float = 1

var seconds_passed:float = 0.0
var minutes_passed:float = 0.0


func _process(delta: float) -> void:
	seconds_passed += delta
	diff_scale = min(1 + (seconds_passed + minutes_passed * 60.0) / 20.0, max_diff_scale)
	spawner.wait_time = 4 / diff_scale
	if seconds_passed >= 60:
		seconds_passed -= 60
		minutes_passed += 1
	timer.text = str(minutes_passed, ":", snapped(seconds_passed, 1))


func _on_spawner_timeout() -> void:
	var new_enemy = enemy_list["Test_Enemy"]["scene"]
	var is_boss:bool = false
	for i in enemy_list:
		var ran_num = randf_range(1, 10)
		if ran_num >= enemy_list[i]["weight"]:
			if i == "Test_Boss":
				if !is_instance_valid(boss_on_field):
					new_enemy = enemy_list[i]["scene"]
					is_boss = true
			else:
				new_enemy = enemy_list[i]["scene"]
			
			break
	
	
	var enemy = new_enemy.instantiate()
	if is_boss:
		boss_on_field = enemy
	enemy.position = enemy_spawnpoint.position + Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
	enemies.add_child(enemy)
