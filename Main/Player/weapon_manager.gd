extends Node2D

@onready var marker = %Marker2D
@onready var weapon_animation_player = %WeaponAnimationPlayer

@export_category('Scenes')
@export var bullet_scene :PackedScene
@export var casing_scene :PackedScene

@export_category('Trigger Settings')
@export_range(0, 1) var shake_camera_force :float = 0.2
@export var shake_camera_decay :float = 0.8
@export var flash_duration :float = 0.25

@export_category('Stats')
@export var damage :float
@export var recoil_force :float = 200
@export var melee_damage :float = 10.0
@export var melee_push_force :float = 100.0

@export var weapon_magazines: int = 3
@export var bullets_per_magazine :int = 6

var interrupt_reload :bool = false
var mouse_direction :Vector2
var bullets_left = weapon_magazines * bullets_per_magazine
var bullets_in_magazine = bullets_per_magazine


func _process(delta):
	look_at(get_global_mouse_position())
	
	mouse_direction = get_global_mouse_position() - global_position
	if mouse_direction.x < 0: scale.y = -1
	else: scale.y = 1
	
	if Input.is_action_just_pressed("shoot"):
		interrupt_reload = true
		if bullets_in_magazine > 0:
			shoot()
		else:
			print('no quedan balas en el magazine para disparar')
	
	elif Input.is_action_just_pressed("hit"):
		interrupt_reload = true
		hit()
	
	elif Input.is_action_just_pressed("reload"):
		interrupt_reload = false
		reload()


func hit():
	weapon_animation_player.stop()
	weapon_animation_player.play('hit')


func reload():
	for i in bullets_per_magazine:
		if bullets_left > 0 and bullets_in_magazine < bullets_per_magazine:
			if interrupt_reload:
				break
			weapon_animation_player.play("reload")
			await get_tree().create_timer(0.6).timeout
			#sonido de bala cargada
			bullets_in_magazine += 1
			bullets_left -= 1


func shoot():
	bullets_in_magazine -= 1
	
	instantiate_bullet()
	instantiate_casing()
	apply_recoil()
	
	weapon_animation_player.stop()
	weapon_animation_player.play('shoot')
	
	GlobalEvents.shake_camera.emit(shake_camera_force, shake_camera_decay)
	GlobalEvents.flash_camera.emit(flash_duration)


func instantiate_bullet():
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_position = marker.global_position
	bullet.global_rotation = marker.global_rotation


func instantiate_casing():
	var casing = casing_scene.instantiate()
	get_tree().root.add_child(casing)
	casing.initialize(
		global_position, #start_position
		Vector2(-scale.y * 150, -150), #initial_velocity
		global_position.y + 12 #floor_position
		)


func apply_recoil():
	var player = get_parent()
	if player.is_in_group('player'):
		if player.has_method('take_impulse'):
			var direction = -1 * mouse_direction.normalized()
			player.take_impulse(recoil_force, direction)


func _on_hurt_box_body_entered(body):
	if body.has_method('take_damage'):
		body.take_damage(melee_damage)
		#body.velocity += melee_push_force * mouse_direction.normalized()
		GlobalEvents.shake_camera.emit(shake_camera_force, shake_camera_decay)
	
	if body.has_method('take_impulse'):
		body.take_impulse(melee_push_force, mouse_direction.normalized())
