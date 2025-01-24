class_name Interest
extends Node2D

@export var circle: Sprite2D
@export var art: Sprite2D

var interest_data: InterestData : set = _set_interest_data


func _set_interest_data(values: InterestData):
	interest_data = values
	if not is_node_ready():
		await ready
	circle.modulate = interest_data.color
	art.texture = interest_data.art
