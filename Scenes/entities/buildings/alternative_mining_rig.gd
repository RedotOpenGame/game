extends CharacterBody3D

const res_scene:PackedScene = preload("res://Scenes/misc/resource_pile.tscn")
const rand_limit = 3
@export var piles_amount:int = 3 ##Amount of scrap piles it will mine
@export var piles_scrap:int = 3 ##Amount of scrap in individual scrap pile
@onready var label_3d: Label3D = $Label3D
@onready var miner_timer: Timer = $MinerTimer


func _process(delta: float) -> void:
	label_3d.text = str("MINING:", snapped(miner_timer.time_left, 0.1), "\nPILES LEFT:", piles_amount)

func _on_miner_timer_timeout() -> void:
	var scene = res_scene.instantiate()
	var rand1:float = randf_range(-rand_limit, rand_limit)
	var rand2:float = randf_range(-rand_limit, rand_limit)
	scene.position = Vector3(rand1, -2, rand2)
	scene.scrap = piles_scrap

	add_child(scene)
	var tween = get_tree().create_tween()
	tween.tween_property(scene, "position", Vector3(rand1, -1, rand2), 3)
	piles_amount -= 1
	if piles_amount > 0:
		$MinerTimer.start()
