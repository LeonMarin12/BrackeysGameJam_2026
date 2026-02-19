extends CharacterBody2D

@export var speed: float = 150.0
@export var acceleration: float = 10.0
@export var max_health: float = 100.0
@export var max_sanity: float = 100.0

@onready var weapon_manager = %WeaponManager

var health := max_health
var sanity := max_sanity

func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target_velocity = direction * speed
	velocity = velocity.lerp(target_velocity, acceleration * delta)
	move_and_slide()


func pick_drop(drop_name):
	if drop_name == 'drop':
		print('drop picked')


func take_impulse(impulse_force, direction):
	velocity += direction * impulse_force


func restore_health(value) -> bool:
	if health == max_health: return false
	elif (health + value) > max_health: 
		health = max_health
	else:
		health += value
	return true

func restore_sanity(value) -> bool:
	if sanity >= max_sanity * 1.9 : return false
	elif (sanity + value) > max_sanity: 
		sanity = max_sanity
	else: 
		sanity += value
	return true

func restore_ammo(value):
	if weapon_manager.bullets_left == weapon_manager.max_bullets: return false
	if (weapon_manager.bullets_left + value) > weapon_manager.max_bullets: 
		weapon_manager.bullets_left = weapon_manager.max_bullets
	else: weapon_manager.bullets_left += value
	return true

func take_damage(damage):
	health -= damage
	GlobalEvents.shake_camera.emit(0.35, 0.8)
	DamageNumbers.display_number(damage, global_position)
	if health <= 0.0:
		die()


func die():
	print('YOU DIE')
