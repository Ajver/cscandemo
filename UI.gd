extends CanvasLayer

func _on_Button_pressed():
	JS_API.new_event("alert", "This message comes from Godot application")

func show_message(msg:String) -> void:
	$MessagePopup.dialog_text = msg
	$MessagePopup.popup()
