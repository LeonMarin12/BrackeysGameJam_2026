extends Node2D

@onready var marker = %Marker2D

@export var bullet_scene :PackedScene

@export_category('Trigger Settings')
@export_range(0, 1) var shake_camera_force :float = 0.2
@export var shake_camera_decay :float = 0.8
@export var flash_duration :float = 0.25
@export var recoil_force :float = 300

var mouse_direction :Vector2


func _process(delta):
	look_at(get_global_mouse_position())
	
	mouse_direction = get_global_mouse_position() - global_position
	if mouse_direction.x < 0: scale.y = -1
	else: scale.y = 1
	
	if Input.is_action_just_pressed("shoot"):
		shoot()


func shoot():
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_position = marker.global_position
	bullet.global_rotation = marker.global_rotation
	
	apply_recoil()
	
	GlobalEvents.shake_camera.emit(shake_camera_force, shake_camera_decay)
	GlobalEvents.flash_camera.emit(flash_duration)


func apply_recoil():
	var player = get_parent()
	if player.is_in_group('player'):
		if player.has_method('take_impulse'):
			var direction = -1 * mouse_direction.normalized()
			player.take_impulse(recoil_force, direction)
