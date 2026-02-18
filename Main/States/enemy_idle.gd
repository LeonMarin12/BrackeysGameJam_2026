extends State
class_name EnemyIdle

var move_direction :Vector2
var wander_time :float
var wait_time :float
var is_waiting :bool = false

@export var enemy : CharacterBody2D
@export var animation_player :AnimationPlayer
@export var idle_move_speed :float = 10.0


var player :CharacterBody2D

func randomize_wander():
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_time = randf_range(1, 3)
	is_waiting = false

func randomize_wait():
	wait_time = randf_range(1, 2)
	is_waiting = true

func Enter():
	player = get_tree().get_first_node_in_group('player')
	randomize_wander()

func Update(delta: float):
	if is_waiting:
		if wait_time > 0:
			wait_time -= delta
		else:
			randomize_wander()
	else:
		if wander_time > 0:
			wander_time -= delta
		else:
			randomize_wait()

func Physics_Update(delta :float):
	if enemy:
		if is_waiting:
			enemy.velocity = Vector2.ZERO
			if animation_player.has_animation('idle'):
				animation_player.play('idle')
		else:
			enemy.velocity = move_direction * idle_move_speed
			if animation_player.has_animation('walk'):
				animation_player.play('walk')
