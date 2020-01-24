extends Spatial

onready var mesh = $simple 

func _ready():
	
	print(mesh.mesh.surface_get_arrays(0)[0][0])
