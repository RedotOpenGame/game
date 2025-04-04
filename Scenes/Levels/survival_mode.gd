extends Node3D

var player_char = preload("res://Scenes/players/player_actor.tscn")

@onready var enemy_spawnpoint: Marker3D = $EnemySpawnpoint
@onready var enemies: Node3D = $Entities/Enemies
@onready var intermission: Timer = $Intermission
@onready var wave_counter: Label = $CanvasLayer/WaveCounter
@onready var resource_spawnpoint: Marker3D = $ResourceSpawnpoint
@onready var resources: Node3D = $Entities/Resources
@onready var intermission_bar: ProgressBar = $CanvasLayer/IntermissionBar
@onready var enemy_spawnpoints: Node3D = $EnemySpawnpoints


const second_part_music = "res://assets/Music/Robotic Wasteland.mp3"

var resource_pile_scene:PackedScene = preload("res://Scenes/misc/resource_pile.tscn")
#resources will spawn every new wave so player could collect them and make new bots

var game_started:bool = false

var multiple_entrances:bool = false
var curr_wave:int = 0
var is_in_intermission:bool = false
var enemy_list:Dictionary = {
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
var wave_structure:Dictionary = {
	1:{"Test_Enemy":1}, #just a single enemy.
	2:{"Test_Enemy":6}, #more of them.
	3:{"Test_Enemy":4, "Shooter":3}, #enemies have guns now.
	4:{"Test_Enemy":3, "Shooter":5}, #nothing new.
	5:{"Test_Boss":1, "Test_Enemy":4}, #boss enemy???
	6:{"Test_Enemy_t2":1, "Shooter":4, "Shielder":2}, #new tier, and also shielders to ruin your life
	7:{"Test_Enemy_t2":6, "Test_Enemy":5, "Shielder":4}, #more of them are coming, no shooters
	8:{"Test_Boss":1, "Shooter_t2":5, "Test_Enemy":12, "Shielder":3},
	9:{"Test_Boss":1, "Test_Enemy":4, "Shooter":4, "Shooter_t2":4, "Test_Enemy_t2":4, "Shielder":5}, #little bit of this, little bit of that ahh wave
	10:{"Altefo":1}, #Altefo is attacking!
	11:{"Test_Enemy":12, "Test_Enemy_t2":8, "Shielder":5},
	12:{"Shooter":8, "Shooter_t2":6, "Shielder":12},
	13:{"Test_Boss":2, "Shooter_t2":5, "Test_Enemy":9, "Test_Enemy_t2":6},
	14:{"Shielder":15, "Shielder_t2":10},
	15:{"Test_Boss":2, "Test_Enemy":12, "Test_Enemy_t2":4, "Medic":4},
	16:{"Shooter":8, "Shooter_t2":6, "Shielder":15, "Medic":6},
	17:{"Shielder_t2":10, "Shooter_t2":13, "Shooter":7},
	18:{"Shielder_t2":10, "Shooter_t2":17, "Test_Boss":2},
	19:{"Shielder_t2":5, "Shielder":5, "Shooter_t2":5, "Shooter":5, "Test_Enemy_t2":5, "Test_Enemy":5, "Medic":5, "Test_Boss":5}, #little bit of this, little bit of that ahh wave part 2
	20:{"Altefo":1, "Medic":5, "Test_Boss":3, "Test_Enemy_t2":14}, #altefo is back for fucking revenge, and he brought friends
}

var spawn_points:int = 0

func _ready() -> void:
	intermission_bar.max_value = intermission.wait_time
	for i in MultiplayerHelper.Players:
		var player = player_char.instantiate()
		player.name = str(MultiplayerHelper.Players[i].id)
		player.position = $PlayerSpawnpoint.position + Vector3(randi_range(-5, 5), 0, randi_range(-5, 5))
		$Players.add_child(player)
	if MultiplayerHelper.Players == {}:
		var player = player_char.instantiate()
		player.position = $PlayerSpawnpoint.global_position
		$Players.add_child(player)
	start_vote()

func _process(delta: float) -> void:
	if enemies.get_child_count() == 0 and !is_in_intermission and game_started:
		is_in_intermission = true
		intermission.start()
		for i in get_tree().get_nodes_in_group("Ally"):
			i.heal_func(666)
	intermission_bar.value = intermission.time_left

@rpc("call_local")
func new_wave() -> void:
	for i in get_tree().get_nodes_in_group("Farm"):
		i.get_resource()

	is_in_intermission = false
	curr_wave += 1
	if curr_wave == 10:
		$Music.stream = load(second_part_music)
	if curr_wave % 5 == 0:
		$BossMusic.play()
		$Music.stop()
	else:
		$BossMusic.stop()
		if !$Music.playing:
			$Music.play()
	spawn_points = curr_wave * 5
	wave_counter.text = str("Wave: ", curr_wave)
	if !wave_structure.has(curr_wave):
		wave_counter.text = str("Wave: no more lmao")
		return
	for i in wave_structure[curr_wave]:
		
		for j in wave_structure[curr_wave][i]:
			spawn_enemy(i)
	for i in range(floor(curr_wave / 5) + 1):
		spawn_resource_pile()

@rpc("any_peer", "call_local")
func spawn_enemy(enmy_name) -> void:
	var enemy = enemy_list[enmy_name][0].instantiate()
	if multiple_entrances:
		enemy.position = enemy_spawnpoints.get_children().pick_random().position + Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
	else:
		enemy.position = enemy_spawnpoint.position + Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
	enemies.add_child(enemy)

@rpc("any_peer", "call_local")
func spawn_resource_pile() -> void:
		var scene = resource_pile_scene.instantiate()
		scene.position = resource_spawnpoint.position + Vector3(randf_range(-20, 20), 0.5, randf_range(-20, 20))
		scene.scrap = 5
		scene.scale = Vector3(1.8, 1.8, 1.8)
		resources.add_child(scene)

func _on_intermission_timeout() -> void:
	new_wave.rpc()


func _on_new_wave_now_pressed() -> void:
	new_wave.rpc()
	restart_intermission.rpc()
	$CanvasLayer/NewWaveNow.release_focus()

@rpc("any_peer", "call_local")
func restart_intermission() -> void:
	intermission.start()

func _on_single_entrance_pressed() -> void:
	if $Players.get_child_count() == 1:
		game_started = true
		multiple_entrances = false
		select_mode.visible = false
	else:
		if multiplayer.is_server():
		# Host votes locally
			submit_vote("mode1")
		else:
		# Client sends vote to host (peer ID 1)
			submit_vote.rpc_id(1, "mode1")


func _on_multiple_entrance_2_pressed() -> void:
	if $Players.get_child_count() == 1:
		game_started = true
		multiple_entrances = true
		select_mode.visible = false
	else:
		if multiplayer.is_server():
		# Host votes locally
			submit_vote("mode2")
		else:
		# Client sends vote to host (peer ID 1)
			submit_vote.rpc_id(1, "mode2")

#Code generated by Deepseek-r1
#Modified by Pewweper
var votes = {}
var is_voting = false
@onready var vote_timer = $VoteTimer
@onready var select_mode: Control = $CanvasLayer/SelectMode
@onready var votes_1: Label = $CanvasLayer/SelectMode/Votes1
@onready var votes_2: Label = $CanvasLayer/SelectMode/Votes2


# Host starts the vote
func start_vote():
	votes_1.visible = true
	votes_2.visible = true
	if is_voting:
		return
	is_voting = true
	votes.clear()
	vote_timer.start(30)  # 30-second voting period
	print("voting started")
	#rpc("show_vote_ui")  # Show UI on all clients

# Clients send votes to the server
@rpc("any_peer")
func submit_vote(mode):
	# Only the server processes votes
	if not multiplayer.is_server() or not is_voting:
		return

	# Get the sender's ID (clients use RPC, host calls directly)
	var sender_id:int = 0
	if multiplayer.get_remote_sender_id() == 0:
		# This is the host voting locally (sender_id = 1)
		sender_id = 1
	else:
		# This is a client (sender_id = remote peer ID)
		sender_id = multiplayer.get_remote_sender_id()

	# Prevent duplicate votes
	if sender_id in votes:
		return

	# Validate sender is connected (including host)
	var peers = multiplayer.get_peers()
	if sender_id != 1 and not peers.has(sender_id):
		return  # Invalid sender

	votes[sender_id] = mode
	# Check if all players (host + peers) have voted
	print("vote made for: ", mode)
	if votes.size() == peers.size() + 1:
		end_vote()

func end_vote():
	vote_timer.stop()
	is_voting = false
	var tally = {"mode1": 0, "mode2": 0}
	for vote in votes.values():
		tally[vote] += 1
	var winner = "mode1" if tally["mode1"] >= tally["mode2"] else "mode2"
	rpc("announce_winner", winner)  # Inform all clients

@rpc("call_local")
func announce_winner(mode):
	select_mode.visible = false
	game_started = true
	print("Game mode selected: ", mode)
	# Update game mode here (e.g., reload scene or adjust settings)
	if mode == "mode1":
		multiple_entrances = false
	elif mode == "mode2":
		multiple_entrances = true

func _on_vote_timer_timeout():
	if multiplayer.is_server():
		end_vote()
