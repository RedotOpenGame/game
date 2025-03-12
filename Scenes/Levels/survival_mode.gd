extends Node3D

@onready var enemy_spawnpoint: Marker3D = $EnemySpawnpoint
@onready var enemies: Node3D = $Entities/Enemies

#resources will spawn every new wave so player could collect them and make new bots


var curr_wave:int = 0
var enemy_list:Dictionary = {
	#"Example":preload("path/to/enemy/scene.tscn"),
	"Test_Enemy":preload("res://Scenes/entities/Enemies/test_enemy.tscn"),
}
var wave_structure:Dictionary = {
	1:{"Test_Enemy":3},
	2:"",
	3:"",
	4:"",
	5:"",
	6:"",
	7:"",
	8:"",
	9:"",
	10:"",
}

var spawn_points:int = 0

func _ready() -> void:
	new_wave()

func new_wave() -> void:
	curr_wave += 1
	spawn_points = curr_wave * 5
	for i in wave_structure[curr_wave]:
		
		for j in wave_structure[curr_wave][i]:
			var enemy = enemy_list[i].instantiate()
			enemy.position = enemy_spawnpoint.position + Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
			enemies.add_child(enemy)
