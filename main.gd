extends Node

@export var bubble_scene: PackedScene
@export var connection_line_scene: PackedScene
@export var bubbles: Array[BubbleData]

enum States {BASE, CONNECTING, DRAGGING}

var current_state := States.BASE
var current_connection_line: ConnectionLine
var targeted_interest: Interest
var targeted_bubble: Bubble
var dragged_bubble: Bubble

func _ready() -> void:
	for bubble_data in bubbles:
		var new_bubble = create_bubble(bubble_data)
		new_bubble.bubble_mouse_entered.connect(_on_bubble_mouse_entered)
		new_bubble.bubble_mouse_exited.connect(_on_bubble_mouse_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		if current_state == States.BASE:
			if targeted_interest != null:
				current_connection_line = connection_line_scene.instantiate() as ConnectionLine
				add_child(current_connection_line)
				current_connection_line.starting_interest = targeted_interest
				current_state = States.CONNECTING
			
			elif targeted_bubble != null:
				targeted_bubble.dragging = true
				dragged_bubble = targeted_bubble
				current_state = States.DRAGGING
				
	
	if event.is_action_released("left_mouse"):
		if current_state == States.CONNECTING:
			if targeted_interest == null:
				current_connection_line.queue_free()
			else:
				current_connection_line.ending_interest = targeted_interest
			current_state = States.BASE
		
		if current_state == States.DRAGGING:
			dragged_bubble.dragging = false
			dragged_bubble.linear_velocity = Vector2.ZERO
			current_state = States.BASE


func create_bubble(bubble_data: BubbleData) -> Bubble:
	var new_bubble := bubble_scene.instantiate() as Bubble
	add_child(new_bubble)
	new_bubble.bubble_data = bubble_data
	
	for interest in new_bubble.interests:
		interest.mouse_entered.connect(_on_interest_mouse_entered)
		interest.mouse_exited.connect(_on_interest_mouse_exited)
	
	var screenSize = get_viewport().get_visible_rect().size
	var rng = RandomNumberGenerator.new()
	var rndX = rng.randi_range(0, screenSize.x)
	var rndY = rng.randi_range(0, screenSize.y)
	new_bubble.position = Vector2(rndX, rndY)
	
	return new_bubble


func _on_interest_mouse_entered(interest: Interest) -> void:
	targeted_interest = interest


func _on_interest_mouse_exited(_interest: Interest) -> void:
	targeted_interest = null


func _on_bubble_mouse_entered(bubble: Bubble) -> void:
	targeted_bubble = bubble


func _on_bubble_mouse_exited(_bubble: Bubble) -> void:
	targeted_bubble = null
