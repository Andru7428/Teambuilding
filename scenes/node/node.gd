class_name GameNode
extends Node2D

const radius := 64

@export var node_data: NodeData : set = _set_node_data
@export var circle: Sprite2D
@export var art: Sprite2D
@export var interest_scene: PackedScene

func _set_node_data(values: NodeData):
	node_data = values
	if not is_node_ready():
		await ready
	circle.modulate = node_data.color
	art.texture = node_data.art
	
	var step = 2 * PI / len(node_data.interests)
	for i in range(len(node_data.interests)):
		var interest_data = node_data.interests[i]
		var new_interest = interest_scene.instantiate() as Interest
		new_interest.interest_data = interest_data
		new_interest.global_position = Vector2(sin(i * step), -cos(i * step)) * radius
		add_child(new_interest)
