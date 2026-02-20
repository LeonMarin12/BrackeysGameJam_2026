extends State
class_name EnemyFollow

@export var enemy :CharacterBody2D
@export var animation_player :AnimationPlayer

var player :CharacterBody2D

func Enter():
	player = get_tree().get_first_node_in_group('player')


func Physics_Update(delta :float):
	if enemy.is_dead: return
	
	var direction = player.global_position - enemy.global_position
	
	if direction.length() > enemy.distance_to_attack:
		enemy.move_to_direction(direction.normalized())
		if animation_player.has_animation('walk'):
				animation_player.play('walk')
		
	else:
		Transitioned.emit(self, 'EnemyAttack')
		enemy.velocity = Vector2()
	
	if direction.length() > 500:
		Transitioned.emit(self, 'enemyidle')
