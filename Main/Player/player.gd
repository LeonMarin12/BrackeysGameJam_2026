extends CharacterBody2D

@export var speed: float = 200.0
@export var acceleration: float = 20.0

func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target_velocity = direction * speed
	velocity = velocity.lerp(target_velocity, acceleration * delta)
	move_and_slide()


func pick_drop(drop_name):
	if drop_name == 'drop':
		print('drop picked')
