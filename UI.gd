extends CanvasLayer

func _on_Button_pressed():
	JS_API.new_event("alert", "This message comes from Godot application")
