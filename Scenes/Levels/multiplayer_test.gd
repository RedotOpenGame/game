extends Control

@export var Address = "127.0.0.1"
@export var port = 212
var peer

func _ready() -> void:
	multiplayer.peer_connected.connect(PlayerConnected)
	multiplayer.peer_disconnected.connect(PlayerDisconnected)
	multiplayer.connected_to_server.connect(ConnectToServer)
	multiplayer.connection_failed.connect(ConnectionFailure)

func _input(event: InputEvent) -> void:
	if visible:
		if Input.is_action_just_pressed("h"):
			print("game hosted")
			_on_host_game_pressed()
		if Input.is_action_just_pressed("j"):
			print("game joined")
			_on_join_game_pressed()
		if Input.is_action_just_pressed("k"):
			_on_start_game_pressed()

@rpc("any_peer", "call_local") #this must be line above function we need RPC for.
func StartGame() -> void:
	#var player = player_char.instantiate()
	#player.position = $PlayerSpawnpoint.position
	#$PlayerSpawnpoint.add_child(player)
	self.hide()
	var scene = load("res://Scenes/Levels/multiplayer_test.tscn").instantiate()
	get_tree().root.add_child(scene)
	
@rpc("any_peer")
func SendPlayerInfo(plr_name, id):
	if !MultiplayerHelper.Players.has(id):
		MultiplayerHelper.Players[id] = {
			"name": plr_name,
			"id":id,
			"scrap": 0
		}
		print("player added: ", plr_name)
	if multiplayer.is_server():
		for i in MultiplayerHelper.Players:
			SendPlayerInfo.rpc(MultiplayerHelper.Players[i].name, i)
#During connection, we call that on the server and the client
func PlayerConnected(id):
	print("Player Connected ", id)

#for server and clients
func PlayerDisconnected(id):
	print("Player Disconnected ", id)
	var players = get_tree().get_nodes_in_group("Player")
	var units = get_tree().get_nodes_in_group("Unit")
	var plr_removal
	for player in players:
		if player.name == str(id):
			plr_removal = player
	for unit in units:
		if unit._leader == plr_removal:
			unit.queue_free() #remove all of the disconnected player's units
	plr_removal.queue_free() #remove the disconnected player
	MultiplayerHelper.Players.erase(id)

#only for clients
func ConnectToServer():
	SendPlayerInfo.rpc_id(1, $Stuff/Entername.text, multiplayer.get_unique_id())
#only for clients
func ConnectionFailure():
	print("fuck")


func UPnP_setup() -> void: #Doesn't work for me - Pewweper
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
	"UPNP Discover failed! Fucking hell! Error %s" % discover_result)
	
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
	"UPNP Invalid Gateway!")
	
	var map_result = upnp.add_port_mapping(port)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
	"UPNP Port mapping failure! Error %s" % map_result)
	
	print("Oh hey, it's working! Join Address: %s" % upnp.query_external_address())


func _on_host_game_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 8)
	if error != OK:
		print("Oops we fucked up: ", error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_NONE)
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players...")
	#UPnP_setup()
	SendPlayerInfo($Stuff/Entername.text, multiplayer.get_unique_id())


func _on_join_game_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_NONE)
	multiplayer.set_multiplayer_peer(peer)



func _on_start_game_pressed() -> void:
	StartGame.rpc()
