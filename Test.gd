extends Spatial

func _ready():
	JS_API.connect("event", self, "_on_event")

func _on_event(event_name, event_data):
	match event_name:
		'flip_camera':
			flip_camera()
		_:
			prints("Unexpected event:", event_name, event_data)
	
func flip_camera() -> void:
	$Camera.rotate_z(PI)

func _process(delta):
	$can.rotate_x(delta)
	$can.rotate_y(delta)
	$can.rotate_z(-delta)
	
