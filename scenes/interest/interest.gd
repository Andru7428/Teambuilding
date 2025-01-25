class_name Interest
extends Node2D

signal mouse_entered(interest: Interest)
signal mouse_exited(interest: Interest)
signal connecting_changed(interest: Interest)

@export var art: Sprite2D

var interest_data: InterestData : set = _set_interest_data
var connection: ConnectionLine : set = _set_connection


func connected() -> bool:
	if connection != null:
		return connection.starting_interest != null and connection.ending_interest != null
	return false


func _set_interest_data(values: InterestData) -> void:
	interest_data = values
	if not is_node_ready():
		await ready
	art.texture = interest_data.art


func _set_connection(value: ConnectionLine):
	connection = value
	connecting_changed.emit(self)


func _on_area_2d_mouse_entered() -> void:
	mouse_entered.emit(self)


func _on_area_2d_mouse_exited() -> void:
	mouse_exited.emit(self)


func get_neighbour() -> Bubble:
	if connection.starting_interest == self:
		return connection.ending_interest.get_parent()
	else:
		return connection.starting_interest.get_parent()
