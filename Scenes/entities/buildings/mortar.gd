extends GeneralBuilding


@export var mortar_scene: PackedScene = preload("res://Scenes/entities/Projectiles/Player/bomb.tscn")
@onready var marker = $Marker3D
@onready var health_label: Label3D = $HealthLabel

#@onready var player = get_tree().get_first_node_in_group("third_slot")

var min_distance_to_player = 1
var SPEED = 3.0
var target

func _ready():
	health_label.text = str("Health: ", health, "/", max_health)
	$PlayerOwner.visible = show_name
	$PlayerOwner.text = str("Placed by: ", player_name)

func _process(delta: float) -> void:
	target = find_closest_global_target("Hostile")

	if not is_on_floor():
		velocity += get_gravity() * delta

func damage_func(amount:float) -> void:
	health -= amount
	health_label.text = str("Health: ", health, "/", max_health)
	if health <= 0:
		death()

func fire_mortar():
	if is_instance_valid(target):
		var mortar = mortar_scene.instantiate()
		add_sibling(mortar)
		mortar.global_position = marker.global_position
		mortar.initialize(target.global_position)


func _on_fire_timeout() -> void:
	fire_mortar()
