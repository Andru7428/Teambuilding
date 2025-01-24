class_name Interest
extends Node2D

const ARC_POINTS := 16

@export var circle: Sprite2D
@export var art: Sprite2D
@export var line_scene: PackedScene

var connecting: bool = false

var interest_data: InterestData : set = _set_interest_data


func _set_interest_data(values: InterestData):
	interest_data = values
	if not is_node_ready():
		await ready
	art.texture = interest_data.art


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("left_mouse"):
		if not StateMachine.connecting:
			var new_line = line_scene.instantiate() as Line
			new_line.target_1 = self
			add_child(new_line)
			StateMachine.active_line = new_line
			StateMachine.connecting = true
		elif StateMachine.active_line != null:
			StateMachine.active_line.target_2 = self
			StateMachine.connecting = false
			StateMachine.active_line = null


func _get_points() -> Array:
	var points = []
	var start = self.position
	start.y += circle.texture.get_height() / 2
	var target = get_local_mouse_position()
	var distance = target - start
	
	for i in range(ARC_POINTS):
		var t = (1.0 / ARC_POINTS) * i
		var x = start.x + (distance.x / ARC_POINTS) * i
		var y = start.y + ease_out_cubic(t) * distance.y
		points.append(Vector2(x, y))
	points.append(target)
	return points


func ease_out_cubic(number: float) -> float:
	return 1.0 - pow(1.0 - number, 4.0)
