class_name Bubble
extends RigidBody2D

const RADIUS := 110

@export var bubble_data: BubbleData : set = _set_node_data
@export var circle: Sprite2D
@export var art: Sprite2D
@export var interest_scene: PackedScene

var interests: Array[Interest]
var dragging = false

func _physics_process(delta: float) -> void:
	if dragging:
		linear_damp = 0
		var direction = get_global_mouse_position() - global_position
		linear_velocity = direction * 1000 * delta
	else:
		linear_damp = 10

func _set_node_data(values: BubbleData):
	bubble_data = values
	if not is_node_ready():
		await ready
	art.texture = bubble_data.art
	
	var step = 2 * PI / len(bubble_data.interests)
	for i in range(len(bubble_data.interests)):
		var interest_data = bubble_data.interests[i]
		var new_interest = interest_scene.instantiate() as Interest
		new_interest.interest_data = interest_data
		new_interest.position = Vector2(sin(i * step), -cos(i * step)) * RADIUS
		add_child(new_interest)
		interests.append(new_interest)


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("left_mouse"):
		dragging = true
		
	elif event.is_action_released("left_mouse") and dragging:
		dragging = false
		linear_velocity = Vector2.ZERO
