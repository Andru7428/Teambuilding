class_name Bubble
extends RigidBody2D

const RADIUS := 110

signal bubble_mouse_entered(bubble: Bubble)
signal bubble_mouse_exited(bubble: Bubble)
signal state_changed

@export var bubble_data: BubbleData : set = _set_node_data
@export var bubble: Sprite2D
@export var art: Sprite2D
@export var interest_scene: PackedScene

var interests: Array[Interest]
var dragging = false
var happy := false : set = _set_happy
var connected_to_main := false

func _physics_process(delta: float) -> void:
	if dragging:
		linear_damp = 0
		var direction = get_global_mouse_position() - global_position
		linear_velocity = direction * 1000 * delta
	else:
		linear_damp = 10


func _set_node_data(values: BubbleData) -> void:
	bubble_data = values
	if not is_node_ready():
		await ready
	if bubble_data.main:
		art.texture = bubble_data.art_happy
		happy = true
		bubble.hide()
	else:
		art.texture = bubble_data.art_sad
	
	var step = 2 * PI / len(bubble_data.interests)
	for i in range(len(bubble_data.interests)):
		var interest_data = bubble_data.interests[i]
		var new_interest = interest_scene.instantiate() as Interest
		new_interest.interest_data = interest_data
		new_interest.position = Vector2(sin(i * step), -cos(i * step)) * RADIUS
		add_child(new_interest)
		interests.append(new_interest)
		new_interest.connecting_changed.connect(_on_interest_connection_changed)


func _on_area_2d_mouse_entered() -> void:
	bubble_mouse_entered.emit(self)


func _on_area_2d_mouse_exited() -> void:
	bubble_mouse_exited.emit(self)


func _on_interest_connection_changed(_interest: Interest) -> void:
	update_state()


func update_state() -> void:
	if !bubble_data.main:
		for interest in interests:
			if !interest.connected():
				happy = false
				return
		
		if connected_to_main != is_connected_to_main([]):
			connected_to_main = !connected_to_main 
			for neighbour in get_neighbours():
				neighbour.update_state()
		
		if !connected_to_main:
			happy = false
			return
		happy = true


func _set_happy(value: bool):
	happy = value
	if happy:
		art.texture = bubble_data.art_happy
		bubble.hide()
		state_changed.emit()
	else:
		art.texture = bubble_data.art_sad
		bubble.show()


func get_neighbours() -> Array[Bubble]:
	var neighbors = [] as Array[Bubble]
	for interest in interests:
		if interest.connected():
			neighbors.append(interest.get_neighbour())
	return neighbors


func is_connected_to_main(visited: Array[Bubble]) -> bool:
	visited.append(self)
	if bubble_data.main:
		return true
	for neighbour in get_neighbours():
		if !visited.has(neighbour) and neighbour.is_connected_to_main(visited):
				return true
	return false
