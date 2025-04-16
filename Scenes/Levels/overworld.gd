extends Node3D


@onready var enemy_spawnpoint: Marker3D = $EnemySpawnpoint
@onready var spawn_ui: CanvasLayer = $enemyspawner/spawnUI

const enemy_list:Dictionary = {
	#"Example":preload("path/to/enemy/scene.tscn"),
	"Test_Enemy":[preload("res://Scenes/entities/Enemies/test_enemy.tscn"), 5],
	"Shooter":[preload("res://Scenes/entities/Enemies/shooting_enemy.tscn"), 7],
	"Shielder":[preload("res://Scenes/entities/Enemies/shield_enemy.tscn"), 9],
	"Test_Boss":[preload("res://Scenes/entities/Enemies/test_boss.tscn"), 30],
	"Test_Enemy_t2":[preload("res://Scenes/entities/Enemies/test_enemy_tier_two.tscn"), 10],
	"Shooter_t2":[preload("res://Scenes/entities/Enemies/shooting_enemy_tier_two.tscn"), 14],
	"Altefo":[preload("res://Scenes/entities/Enemies/altefo_boss.tscn"), 250],
	"Shielder_t2":[preload("res://Scenes/entities/Enemies/shield_enemy_tier_two.tscn"), 18],
	"Medic":[preload("res://Scenes/entities/Enemies/enemy_medic.tscn"), 17],
}
func _on_enemyspawner_body_entered(body: Node3D) -> void:

	spawn_ui.visible = true


func _on_hide_menu_pressed() -> void:
	spawn_ui.visible = false


func _on_test_enemy_pressed() -> void:
	var inst = enemy_list["Test_Enemy"][0].instantiate()
	print(inst)
	inst.position = enemy_spawnpoint.position + Vector3(randf_range(-6, 6), 0 , randf_range(-6, 6))
	add_child(inst)


func _on_shooter_pressed() -> void:
	var inst = enemy_list["Shooter"][0].instantiate()
	inst.position = enemy_spawnpoint.position + Vector3(randf_range(-6, 6), 0 , randf_range(-6, 6))
	add_child(inst)


func _on_shielder_pressed() -> void:
	var inst = enemy_list["Shielder"][0].instantiate()
	inst.position = enemy_spawnpoint.position + Vector3(randf_range(-6, 6), 0 , randf_range(-6, 6))
	add_child(inst)


func _on_test_boss_pressed() -> void:
	var inst = enemy_list["Test_Boss"][0].instantiate()
	inst.position = enemy_spawnpoint.position + Vector3(randf_range(-6, 6), 0 , randf_range(-6, 6))
	add_child(inst)


func _on_test_enemy_2_pressed() -> void:
	var inst = enemy_list["Test_Enemy_t2"][0].instantiate()
	inst.position = enemy_spawnpoint.position + Vector3(randf_range(-6, 6), 0 , randf_range(-6, 6))
	add_child(inst)


func _on_shooter_2_pressed() -> void:
	var inst = enemy_list["Shooter_t2"][0].instantiate()
	inst.position = enemy_spawnpoint.position + Vector3(randf_range(-6, 6), 0 , randf_range(-6, 6))
	add_child(inst)


func _on_shielder_2_pressed() -> void:
	
	var inst = enemy_list["Shielder_t2"][0].instantiate()
	inst.position = enemy_spawnpoint.position + Vector3(randf_range(-6, 6), 0 , randf_range(-6, 6))
	add_child(inst)


func _on_medic_pressed() -> void:
	var inst = enemy_list["Medic"][0].instantiate()
	inst.position = enemy_spawnpoint.position + Vector3(randf_range(-6, 6), 0 , randf_range(-6, 6))
	add_child(inst)


func _on_altefo_pressed() -> void:
	var inst = enemy_list["Altefo"][0].instantiate()
	inst.position = enemy_spawnpoint.position + Vector3(randf_range(-6, 6), 0 , randf_range(-6, 6))
	add_child(inst)


func _on_kill_all_enemies_pressed() -> void:
	for i in get_tree().get_nodes_in_group("Hostile"):
		i.death()
