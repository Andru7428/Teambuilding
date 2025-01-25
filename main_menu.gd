extends Control


func _on_start_button_pressed() -> void:
	$ButtonSound.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://main.tscn")



func _on_exit_button_pressed() -> void:
	$ButtonSound.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().quit()
