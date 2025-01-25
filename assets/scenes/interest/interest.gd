class_name Interest
extends Node2D

#signal connection(inerest: Interest)
signal mouse_entered(interest: Interest)
signal mouse_exited(interest: Interest)

@export var art: Sprite2D

var interest_data: InterestData : set = _set_interest_data


func _set_interest_data(values: InterestData) -> void:
	interest_data = values
	if not is_node_ready():
		await ready
	art.texture = interest_data.art


#func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
#	if event.is_action_pressed("left_mouse") or event.is_action_released("left_mouse"):
#		connection.emit(self)


func _on_area_2d_mouse_entered() -> void:
	mouse_entered.emit(self)


func _on_area_2d_mouse_exited() -> void:
	mouse_exited.emit(self)
