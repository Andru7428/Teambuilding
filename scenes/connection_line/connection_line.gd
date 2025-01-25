class_name ConnectionLine
extends Line2D

# TODO: Make line clickable

const ARC_POINTS := 16

var starting_interest: Interest : set = _set_starting_interest
var ending_interest: Interest : set = _set_ending_interest
var target: Vector2

func _process(_delta: float) -> void:
	if starting_interest != null:
		self.points = _get_points()


func _get_points() -> Array:
	var new_points = []
	var start = starting_interest.global_position
	
	if ending_interest == null:
		target = get_local_mouse_position()
	else:
		target = ending_interest.global_position
		
		
	var distance = target - start
	
	for i in range(ARC_POINTS):
		var t = (1.0 / ARC_POINTS) * i
		var x = start.x + (distance.x / ARC_POINTS) * i
		var y = start.y + ease_out(t) * distance.y
		new_points.append(Vector2(x, y))
	new_points.append(target)
	return new_points


func ease_out(number: float) -> float:
	return 1.0 - pow(1.0 - number, 4.0)


func _set_starting_interest(value: Interest) -> void:
	starting_interest = value
	default_color = _get_avg_color(value)


func _set_ending_interest(value: Interest) -> void:
	ending_interest = value
	if starting_interest == ending_interest \
	or starting_interest.interest_data.resource_path != ending_interest.interest_data.resource_path:
		remove()


func _get_avg_color(interest: Interest) -> Color:
	var color := Color(0, 0, 0)
	var texture_size := interest.art.texture.get_size()
	var image := interest.art.texture.get_image()
	
	for y in range(0, texture_size.y):
		for x in range(0, texture_size.x):
			var pixel := image.get_pixel(x, y)
			color += Color(pixel.r, pixel.g, pixel.b)
			
	color /= texture_size.x * texture_size.y
	return color


func remove() -> void:
	if starting_interest != null:
		starting_interest.connection = null
	if ending_interest != null:
		ending_interest.connection = null
	
	queue_free()
