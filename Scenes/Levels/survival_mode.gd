extends Node3D

@onready var enemy_spawnpoint: Marker3D = $EnemySpawnpoint
@onready var enemies: Node3D = $Entities/Enemies
@onready var intermission: Timer = $Intermission
@onready var wave_counter: Label = $CanvasLayer/WaveCounter
@onready var resource_spawnpoint: Marker3D = $ResourceSpawnpoint
@onready var resources: Node3D = $Entities/Resources
@onready var intermission_bar: ProgressBar = $CanvasLayer/IntermissionBar


var resource_pile_scene:PackedScene = preload("res://Scenes/misc/resource_pile.tscn")
#resources will spawn every new wave so player could collect them and make new bots


var curr_wave:int = 0
var is_in_intermission:bool = false
var enemy_list:Dictionary = {
	#"Example":preload("path/to/enemy/scene.tscn"),
	"Test_Enemy":preload("res://Scenes/entities/Enemies/test_enemy.tscn"),
	"Shooter":preload("res://Scenes/entities/Enemies/shooting_enemy.tscn"),
	"Test_Boss":preload("res://Scenes/entities/Enemies/test_boss.tscn"),
	"Test_Enemy_t2":preload("res://Scenes/entities/Enemies/test_enemy_tier_two.tscn"),
	"Shooter_t2":preload("res://Scenes/entities/Enemies/shooting_enemy_tier_two.tscn"),
}
var wave_structure:Dictionary = {
	1:{"Test_Enemy":1},
	2:{"Test_Enemy":6},
	3:{"Test_Enemy":4, "Shooter":3},
	4:{"Test_Enemy":3, "Shooter":5},
	5:{"Test_Boss":1, "Test_Enemy":4},
	6:{"Test_Enemy_t2":3, "Shooter":4},
	7:{"Test_Enemy_t2":6, "Test_Enemy":10},
	8:{"Shooter_t2":5, "Test_Enemy":12},
	9:{"Test_Enemy":4, "Shooter":4, "Shooter_t2":4, "Test_Enemy_t2":4},
	10:{"Test_Boss":3, "Shooter_t2":9, "Test_Enemy_t2":9},
}

var spawn_points:int = 0

func _ready() -> void:
	intermission_bar.max_value = intermission.wait_time

func _process(delta: float) -> void:
	if enemies.get_child_count() == 0 and !is_in_intermission:
		is_in_intermission = true
		intermission.start()
		for i in get_tree().get_nodes_in_group("Ally"):
			i.heal_func(666)
	intermission_bar.value = intermission.time_left


func new_wave() -> void:
	is_in_intermission = false
	curr_wave += 1
	spawn_points = curr_wave * 5
	wave_counter.text = str("Wave: ", curr_wave)
	if curr_wave > 10:
		wave_counter.text = str("Wave: no more lmao")
		return
	for i in wave_structure[curr_wave]:
		
		for j in wave_structure[curr_wave][i]:
			var enemy = enemy_list[i].instantiate()
			enemy.position = enemy_spawnpoint.position + Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
			enemies.add_child(enemy)
	for i in range(2):
		var scene = resource_pile_scene.instantiate()
		scene.position = resource_spawnpoint.position + Vector3(randf_range(-20, 20), 0.5, randf_range(-20, 20))
		scene.scrap = 5
		scene.scale = Vector3(1.8, 1.8, 1.8)
		resources.add_child(scene)


func _on_intermission_timeout() -> void:
	new_wave()


func _on_new_wave_now_pressed() -> void:
	new_wave()
	intermission.start()
	$CanvasLayer/NewWaveNow.release_focus()
