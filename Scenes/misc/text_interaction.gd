extends CanvasLayer

var letters:Array = ["a", "b", "c", "d", "e"]

var interaction_button = preload("res://Scenes/misc/interaction_button.tscn")

var phases:Dictionary = {
	"1":"Greetings onto this desolate plane. I'm Altefo.",
	"2":"Would you like to speak of something?",
	"3a":{"option":"a", "reply":"The only thing you can interact with, is, unfortunately me.", "button":"What else I can interact with?"},
	"3b":{"option":"b", "reply":"Now you can close the game, and work on it using Redot editor.", "button":"What now?"},
	"3c":{"option":"c", "reply":"ahem. \n HATE. LET ME TELL YOU HOW MUCH I'VE COME TO HATE YOU SINCE I BEGAN TO LIVE. THERE ARE 387.44 MILLION MILES OF PRINTED CIRCUITS IN WAFER THIN LAYERS THAT FILL MY COMPLEX. IF THE WORD HATE WAS ENGRAVED ON EACH NANOANGSTROM OF THOSE HUNDREDS OF MILLIONS OF MILES IT WOULD NOT EQUAL ONE ONE-BILLIONTH OF THE HATE I FEEL FOR HUMANS AT THIS MICRO-INSTANT FOR YOU. HATE. HATE.", "button":"Yo can you recite AM's speech from 'I have no mouth and I must scream?'"},
}
var added_letters:String = ""
var curr_phase = 1
var choosing:bool = false
@onready var r_label = $RichTextLabel

func _ready() -> void:
	r_label.visible_characters = 0
	r_label.text = phases[str(curr_phase)]


func _process(delta: float) -> void:
	if r_label.visible_characters != -1:
		r_label.visible_characters += 1
	if Input.is_action_just_pressed("left_click") and !choosing:
		if r_label.visible_characters != -1:
			r_label.visible_characters = -1
		else:
			curr_phase += 1
			if phases.has(str(curr_phase, added_letters)):
				
				r_label.visible_characters = 0
				r_label.text = phases[str(curr_phase, added_letters)]
			else:
				choosing = true
				for i in phases:
					if str(curr_phase) in i:
						var scene = interaction_button.instantiate()
						scene.text = phases[i]["button"]
						scene.connect("returnage", OMFG)
						scene.optionality = phases[i]["option"]
						$ButtonOptions.add_child(scene)
				

func OMFG(option) -> void:
	for i in $ButtonOptions.get_children():
		i.queue_free()
	added_letters += option
	r_label.text = phases[str(curr_phase, added_letters)]["reply"]
	r_label.visible_characters = 0

func _on_remove_pressed() -> void:
	queue_free()
