extends Control

#var existing_messages:String = ""

@onready var rich_text_label: TextEdit = $RichTextLabel
@onready var line_edit: LineEdit = $LineEdit

@rpc("any_peer", "call_local")
func write_into_chat(nickname,text:String) -> void:
	#existing_messages += text
	#print(existing_messages)
	rich_text_label.text += str(nickname, ":", text, "\n")
	var scroll = rich_text_label.get_v_scroll_bar()
	scroll.value = scroll.max_value
	

func _on_line_edit_text_submitted(new_text: String) -> void:
	write_into_chat.rpc(MultiplayerHelper.Nickname,new_text)
	print(new_text)
