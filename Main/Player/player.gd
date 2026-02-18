extends CharacterBody2D

@export var speed: float = 150.0
@export var acceleration: float = 10.0
@export var max_health: float = 100.0
@export var max_sanity: float = 100.0

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


func take_damage(damage):
	print('auch: ', damage)
	health -= damage
	GlobalEvents.shake_camera.emit(0.35, 0.8)
	if health <= 0.0:
		die()


func die():
	print('YOU DIE')
