extends State
class_name EnemyFollow

@export var enemy :CharacterBody2D

var player :CharacterBody2D

func Enter():
	player = get_tree().get_first_node_in_group('player')


func Physics_Update(delta :float):
	var direction = player.global_position - enemy.global_position
	
	if direction.length() > enemy.distance_to_attack:
		print(enemy.distance_to_attack, ' : ', direction.length())
		enemy.move_to_direction(direction.normalized())
		
	else:
		print('a')
		Transitioned.emit(self, 'EnemyAttack')
		enemy.velocity = Vector2()
	
	if direction.length() > 500:
		Transitioned.emit(self, 'enemyidle')
