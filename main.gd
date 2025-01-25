extends Node

@export var bubble_scene: PackedScene
@export var bubbles: Array[BubbleData]


func _ready() -> void:
	for bubble_data in bubbles:
		create_bubble(bubble_data)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func create_bubble(bubble_data: BubbleData):
	var new_bubble := bubble_scene.instantiate() as Bubble
	new_bubble.bubble_data = bubble_data
	add_child(new_bubble)
	
	var screenSize = get_viewport().get_visible_rect().size
	var rng = RandomNumberGenerator.new()
	var rndX = rng.randi_range(0, screenSize.x)
	var rndY = rng.randi_range(0, screenSize.y)
	
	new_bubble.position = Vector2(rndX, rndY)


func _on_connection_started():
	pass
