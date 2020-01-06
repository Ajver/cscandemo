extends Spatial

const IMAGES_FOLDER = "images/"
#const API_URL = "http://127.0.0.1/cscandemo/"
const API_URL = "https://ajver.github.io/cscandemo/"
const IMAGES_PATH = API_URL + IMAGES_FOLDER

func _ready() -> void:
<<<<<<< HEAD
	load_image_to_mesh_surface("cs-gray.jpg", 0)
	load_image_to_mesh_surface("cs.jpg", 1)

func load_image_to_mesh_surface(image_name:String, surface_id:int = 0) -> void:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var request_url = IMAGES_PATH + image_name
	print(request_url)
=======
	load_image_to_mesh_surface("cs.jpg", 0)
	load_image_to_mesh_surface("cs-gray.jpg", 1)
	pass

func load_image_to_mesh_surface(image_name:String, surface_id:int = 0) -> void:
	var http_request = HTTPRequest.new()
	
	var request_url = IMAGES_PATH + image_name
	print("URL:", request_url)
>>>>>>> 6154125646d168479a10a3bff8ff074030bb3932
	var http_error = http_request.request(request_url)
	http_request.connect("request_completed", self, "_on_HTTPRequest_completed", [http_request, surface_id])
	
	if http_error != OK:
		print("An error occurred in the HTTP request.")
<<<<<<< HEAD
		prints("Error:", http_error)
		http_error.queue_free()
=======
		http_request.queue_free()
	else:
		call_deferred("add_child", http_request)
>>>>>>> 6154125646d168479a10a3bff8ff074030bb3932

func _on_HTTPRequest_completed(result, response_code, headers, body, http_req_node, surface_id) -> void:
	var image = Image.new()
	var image_error = image.load_jpg_from_buffer(body)
	if image_error != OK:
		print("An error occurred while trying to display the image.")
		return
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	
<<<<<<< HEAD
#	var surface_material := SpatialMaterial.new()
	var surface_material = $MeshInstance.get_surface_material(surface_id)
	surface_material.albedo_texture = texture
#	$MeshInstance.set_surface_material(surface_id, surface_material)
	
	http_req_node.queue_free()

func _process(delta):
	$MeshInstance.rotate_y(delta * 0.2)
=======
	var surface_material := SpatialMaterial.new()
	surface_material.albedo_texture = texture
	$MeshInstance.set_surface_material(surface_id, surface_material)
	
	http_req_node.queue_free()

>>>>>>> 6154125646d168479a10a3bff8ff074030bb3932
