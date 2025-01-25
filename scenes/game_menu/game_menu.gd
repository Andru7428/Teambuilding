extends Control


func _ready() -> void:
	self.hide()


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("music"),
		linear_to_db(value)
	)


func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("SFX"),
		linear_to_db(value)
	)


func _on_start_button_pressed() -> void:
	self.hide()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
