extends Spatial

func _ready():
	GodotGateway.connect("event", self, "_on_event")

func _on_event(event_name, event_data):
	match event_name:
		'flip_camera':
			flip_camera()
		'js_event':
			$UI.show_message(event_data)
		_:
			prints("Unexpected event:", event_name, event_data)
	
func flip_camera() -> void:
	$CameraRoot/Camera.rotate_z(PI)

func _process(delta):
	$CameraRoot.rotate_y(delta * 0.2)
	
