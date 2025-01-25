class_name Line
extends Line2D

# TODO: Make line clickable

const ARC_POINTS := 16

var target_1: Interest
var target_2: Interest
var target: Vector2

func _process(delta: float) -> void:
	if target_1 != null:
		self.points = _get_points()


func _get_points() -> Array:
	var points = []
	var start = target_1.position
	
	start.y += target_1.circle.texture.get_height() / 2
	if target_2 == null:
		target = get_local_mouse_position()
	else:
		target = target_2.position
		target.y += target_2.circle.texture.get_height() / 2
		
		
	var distance = target - start
	
	for i in range(ARC_POINTS):
		var t = (1.0 / ARC_POINTS) * i
		var x = start.x + (distance.x / ARC_POINTS) * i
		var y = start.y + ease_out(t) * distance.y
		points.append(Vector2(x, y))
	points.append(target)
	return points

func ease_out(number: float) -> float:
	return 1.0 - pow(1.0 - number, 4.0)
