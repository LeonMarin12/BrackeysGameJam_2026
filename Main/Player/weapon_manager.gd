extends Node2D

@onready var marker = %Marker2D

@export var bullet_scene :PackedScene

func _process(delta):
	look_at(get_global_mouse_position())
	
	var mouse_direction = get_global_mouse_position() - global_position
	if mouse_direction.x < 0: scale.y = -1
	else: scale.y = 1
	
	if Input.is_action_just_pressed("shoot"):
		shoot()


func shoot():
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_position = marker.global_position
	bullet.global_rotation = marker.global_rotation
