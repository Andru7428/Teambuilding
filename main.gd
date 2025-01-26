extends Node

const popup_1 := "Перед тобой твои сотрудники, у каждого 
				из них есть интересы. 
				Объедини всех в соответствии с интересами
				в правильной  последовательности, чтобы сформировать дружный коллектив."


const popup_2 := "О, новые сотрудники! Помни, что иногда для создания новых связей, нужно разорвать старые."

const popup_3 := "Похоже, новые сотрудники имеют ещё больше интересов! Объедини каждый интерес одного сотрудника
с каждым интересом другого, чтобы ещё крепче сплотить команду!"

@export var camera: Camera
@export var bubble_scene: PackedScene
@export var connection_line_scene: PackedScene
@export var stages: Array[Stage]
@export var current_stage := 0 : set = _set_current_stage
@export var skip_intro := false

enum States {BASE, CONNECTING, DRAGGING, INTRO, WAITING_CLICK, ENDING}

var current_state := States.BASE
var current_connection_line: ConnectionLine
var targeted_interest: Interest
var targeted_bubble: Bubble
var dragged_bubble: Bubble

var scale_step: float

func _ready() -> void:
	scale_step = 1.0 / len(stages)
	camera.camera_scale = 1 + scale_step * current_stage
	if skip_intro:
		for i in range(current_stage + 1):
			new_stage(stages[i])
		%Cog.modulate = Color(1, 1, 1, 1)
		%PhoneIcon.modulate = Color(1, 1, 1, 1)
		
		if current_stage == 0:
			await get_tree().create_timer(1).timeout
			open_popup(popup_1)
	else:
		current_state = States.INTRO
		$Intro.show()
		%AnimationPlayer.play("intro")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		if current_state == States.BASE:
			if targeted_interest != null:
				if targeted_interest.connection != null:
					targeted_interest.connection.remove()
				current_connection_line = connection_line_scene.instantiate() as ConnectionLine
				add_child(current_connection_line)
				current_connection_line.starting_interest = targeted_interest
				current_state = States.CONNECTING
			
			elif targeted_bubble != null:
				targeted_bubble.dragging = true
				dragged_bubble = targeted_bubble
				current_state = States.DRAGGING
				$StartDragging.play()
			
	
	if event.is_action_released("left_mouse"):
		if current_state == States.CONNECTING:
			if targeted_interest == null:
				current_connection_line.remove()
			else:
				if current_connection_line.starting_interest.interest_data.resource_path == targeted_interest.interest_data.resource_path \
				and current_connection_line.starting_interest != targeted_interest:
					if targeted_interest.connection != null:
						targeted_interest.connection.remove()
					
					for interest in current_connection_line.starting_interest.get_parent().interests:
						if interest.connected():
							if interest.get_neighbour() == targeted_interest.get_parent():
								interest.connection.remove()

					current_connection_line.ending_interest = targeted_interest
				else:
					current_connection_line.remove()
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


func new_stage(stage: Stage) -> void:
	for bubble_data in stage.new_bubbles:
		var new_bubble = create_bubble(bubble_data)
		new_bubble.bubble_mouse_entered.connect(_on_bubble_mouse_entered)
		new_bubble.bubble_mouse_exited.connect(_on_bubble_mouse_exited)
		new_bubble.state_changed.connect(_on_bubble_state_changed)


func _on_interest_mouse_entered(interest: Interest) -> void:
	targeted_interest = interest


func _on_interest_mouse_exited(_interest: Interest) -> void:
	targeted_interest = null


func _on_bubble_mouse_entered(bubble: Bubble) -> void:
	targeted_bubble = bubble


func _on_bubble_mouse_exited(_bubble: Bubble) -> void:
	targeted_bubble = null


func _on_bubble_state_changed() -> void:
	var bubbles = get_tree().get_nodes_in_group("bubble")
	for bubble in bubbles:
		if !bubble.happy:
			return
	if current_stage + 1 < len(stages):
		current_stage += 1
		new_stage(stages[current_stage])
	else:
		$WinSound.play()
		for bubble in bubbles:
			bubble.visuals.scale = Vector2(0.9, 0.9)
		await get_tree().create_timer(1).timeout
		%AnimationPlayer.play("ending")
		%Ending.show()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "intro":
		current_state = States.WAITING_CLICK
	
	if anim_name == "close_intro":
		$Intro.hide()
		for i in range(current_stage + 1):
			new_stage(stages[i])
		current_state = States.BASE
		
		if current_stage == 0:
			await get_tree().create_timer(1).timeout
			open_popup(popup_1)
	
	if anim_name == "popup1_open":
		%PopupButton1.disabled = false
	
	if anim_name == "popup1_close":
		%PopUp1.hide()
		
	if anim_name == "ending":
		%ExitButton.disabled = false


func _on_start_button_pressed() -> void:
	%AnimationPlayer.play("close_intro")
	$PopSound.play()
	%StartButton.disabled = true
	%AnimatedSprite2D.play("pressed")


func _set_current_stage(value: int) -> void:
	current_stage = value
	if !is_node_ready():
		await ready
	if camera != null:
		camera.camera_scale = 1 + scale_step * current_stage
	
	if current_stage == 1:
		
		await get_tree().create_timer(1).timeout
		open_popup(popup_2, 38)
	
	if current_stage == 3:
		await get_tree().create_timer(1).timeout
		open_popup(popup_3)


func _on_popup_button_1_pressed() -> void:
	$PopUpSound.play()
	%PopupButton1.disabled = true
	%AnimationPlayer.play("popup1_close")


func _on_settings_button_pressed() -> void:
	$StartDragging.play()
	%GameMenu.show()


func open_popup(text: String, font_size: int = 28) -> void:
	%PopupLabel.text = text
	%PopupLabel.add_theme_font_size_override("font_size", font_size)
	$PopUpSound.play()
	%PopUp1.show()
	%AnimationPlayer.play("popup1_open")


func _on_exit_button_pressed() -> void:
	$StartDragging.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://main_menu.tscn")
