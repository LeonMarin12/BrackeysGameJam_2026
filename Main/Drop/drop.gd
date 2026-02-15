extends Sprite2D

@export var drop_name :String

func _on_area_2d_body_entered(body):
	if body.is_in_group('player'):
		if body.has_method('pick_drop'):
			body.pick_drop(drop_name)
			disappear()


func disappear():
	queue_free()
