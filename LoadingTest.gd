extends Spatial

const IMAGES_FOLDER = "images/"
const API_URL = "http://127.0.0.1/cscandemo/"
const IMAGES_PATH = API_URL + IMAGES_FOLDER

func _ready() -> void:
	load_image_to_mesh_surface("cs.jpg", 0)
	load_image_to_mesh_surface("cs-gray.jpg", 1)

func load_image_to_mesh_surface(image_name:String, surface_id:int = 0) -> void:
	var http_request = HTTPRequest.new()
	
	var request_url = IMAGES_PATH + image_name
	print(request_url)
	var http_error = http_request.request(request_url)
	http_request.connect("request_completed", self, "_on_HTTPRequest_completed", [http_request, surface_id])
	
	if http_error != OK:
		print("An error occurred in the HTTP request.")
		http_request.queue_free()
	else:
		call_deferred("add_child", http_request)

func _on_HTTPRequest_completed(result, response_code, headers, body, http_req_node, surface_id) -> void:
	var image = Image.new()
	var image_error = image.load_jpg_from_buffer(body)
	if image_error != OK:
		print("An error occurred while trying to display the image.")
		return
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	
	var surface_material := SpatialMaterial.new()
	surface_material.albedo_texture = texture
	$MeshInstance.set_surface_material(surface_id, surface_material)
	
	http_req_node.queue_free()

