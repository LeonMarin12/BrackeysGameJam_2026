extends Camera2D

@export var mouse_influence: float = 0.2
@export var smoothness: float = 1.0


func _process(delta):
	var mouse_offset = (get_global_mouse_position() - get_parent().global_position) * mouse_influence
	position = position.lerp(mouse_offset, smoothness * delta)
