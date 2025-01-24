class_name Bubble
extends RigidBody2D

const RADIUS := 110

@export var node_data: BubbleData : set = _set_node_data
@export var circle: Sprite2D
@export var art: Sprite2D
@export var interest_scene: PackedScene

var dragging = false


func _physics_process(delta: float) -> void:
	if dragging:
		linear_damp = 0
		var direction = get_global_mouse_position() - global_position
		linear_velocity = direction * 1000 * delta
	else:
		linear_damp = 10

func _set_node_data(values: BubbleData):
	node_data = values
	if not is_node_ready():
		await ready
	art.texture = node_data.art
	
	var step = 2 * PI / len(node_data.interests)
	for i in range(len(node_data.interests)):
		var interest_data = node_data.interests[i]
		var new_interest = interest_scene.instantiate() as Interest
		new_interest.interest_data = interest_data
		new_interest.global_position = Vector2(sin(i * step), -cos(i * step)) * RADIUS
		add_child(new_interest)


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("left_mouse"):
		dragging = !dragging
		linear_velocity = Vector2.ZERO
