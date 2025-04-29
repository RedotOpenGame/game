extends CanvasLayer

var bus_index_music:int
var bus_index_sound:int
const sound_bus_name:String = "SFX"
const music_bus_name:String = "Music"

@export var player:GeneralEntity

@onready var amount: Label = $Units/Combatant/Amount
@onready var amount_2: Label = $Units/Constructor/Amount2
@onready var amount_3: Label = $Units/Collector/Amount3
@onready var demolishing_buildings: TextureRect = $VBoxContainer/Statuses/DemolishingBuildings
@onready var collecting_units: TextureRect = $VBoxContainer/Statuses/CollectingUnits
@onready var health_bar: ProgressBar = $VBoxContainer/HealthBar
@onready var health_label: Label = $VBoxContainer/HealthBar/HealthLabel

@onready var scrap_bar: ProgressBar = $VBoxContainer/ScrapBar
@onready var scrap_label: Label = $VBoxContainer/ScrapBar/ScrapLabel

@onready var pausemenu: Control = $Pausemenu
@onready var music_volume: HSlider = $Pausemenu/MusicVolume


func _ready() -> void:
	if !player:
		print("fuck, the ui has no attached player")
		return

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("m"):
		if music_volume.value != 0:
			music_volume.value = 0
		else:
			music_volume.value = 1

func initialize() -> void:
	bus_index_music = AudioServer.get_bus_index("Music")
	bus_index_sound = AudioServer.get_bus_index(sound_bus_name)
	var value = AudioServer.get_bus_volume_db(bus_index_music)
	music_volume.set_value_no_signal(db_to_linear(value))
	pausemenu.visible = Gameplay.paused
	health_bar.max_value = player.max_health
	scrap_bar.max_value = player.max_scrap
	health_bar.value = player.health
	scrap_bar.value = player.curr_scrap
	health_label.text = str(health_bar.value, "/", health_bar.max_value)
	scrap_label.text = str(scrap_bar.value, "/", scrap_bar.max_value)
	demolishing_buildings.use_parent_material = player.building_demolishing_mode
	collecting_units.use_parent_material = !player.unit_collection_collision.disabled
	if str(player.name) == "PlayerActor":
		pass
	else:
		if player.multi_sync.get_multiplayer_authority() == player.multiplayer.get_unique_id():
			visible = true
		else:
			visible = false

func _process(delta: float) -> void:
	pausemenu.visible = Gameplay.paused
	amount.text = str(player.combatant_amount)
	amount_2.text = str(player.builder_amount)
	amount_3.text = str(player.agriculture_amount)
	health_bar.value = player.health
	scrap_bar.value = player.curr_scrap
	health_label.text = str(health_bar.value, "/", health_bar.max_value)
	scrap_label.text = str(scrap_bar.value, "/", scrap_bar.max_value)
	demolishing_buildings.use_parent_material = player.building_demolishing_mode
	collecting_units.use_parent_material = !player.unit_collection_collision.disabled
	
	

func _on_music_volume_value_changed(value: float) -> void:
			AudioServer.set_bus_volume_db(
			bus_index_music,
			linear_to_db(value)
			)


func _on_resume_pressed() -> void:
	player.on_resune_pressed()
