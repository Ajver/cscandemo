extends Spatial


func _process(delta):
	$can.rotate_x(delta)
	$can.rotate_y(delta)
	$can.rotate_z(-delta)
