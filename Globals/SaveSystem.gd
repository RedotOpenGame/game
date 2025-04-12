extends Node

const MULTIPLAYER_PREF_NAME = "user://multiplayer_settings.json"

func save_mult_pref():
	var contents = {
		"Address":MultiplayerHelper.IPAddress,
		"Port":MultiplayerHelper.Port,
		"Nickname":MultiplayerHelper.Nickname
	}
	var json_string = JSON.stringify(contents)
	var file_access := FileAccess.open(MULTIPLAYER_PREF_NAME, FileAccess.WRITE)
	if not file_access:
		print("An error happened while saving data: ", FileAccess.get_open_error())
		return
	file_access.store_line(json_string)
	file_access.close()

func load_mult_pref():
	if not FileAccess.file_exists(MULTIPLAYER_PREF_NAME):
		return
	var file_access := FileAccess.open(MULTIPLAYER_PREF_NAME, FileAccess.READ)
	var json_string := file_access.get_line()
	file_access.close()

	var json := JSON.new()
	var error := json.parse(json_string)
	if error:
		printerr("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return
	# We saved a dictionary, lets assume is a dictionary
	var data:Dictionary = json.data
	
	if data.get("Address") != null:
		MultiplayerHelper.IPAddress = data.get("Address") 
	if data.get("Port") != null:
		MultiplayerHelper.Port = data.get("Port")
	if data.get("Nickname") != null:
		MultiplayerHelper.Nickname = data.get("Nickname")
