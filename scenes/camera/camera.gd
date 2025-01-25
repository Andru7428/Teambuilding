class_name Camera
extends Node2D

@export_range(1, 2) var camera_scale := 1.0 : set = _set_scale


func _process(delta: float) -> void:
	$Camera2D.zoom = $Camera2D.zoom.move_toward(Vector2(1 / camera_scale, 1 / camera_scale), 0.01)
	#print(camera_scale)


func _set_scale(value: float) -> void:
	camera_scale = value
	scale = Vector2(camera_scale, camera_scale)
