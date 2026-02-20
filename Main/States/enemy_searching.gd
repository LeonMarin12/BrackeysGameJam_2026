extends State
class_name EnemySearching

@export var enemy :CharacterBody2D
@export var animation_player :AnimationPlayer

var player :CharacterBody2D
var position_to_search :Vector2

func Enter():
	player = get_tree().get_first_node_in_group('player')
	position_to_search = player.global_position


func Physics_Update(delta :float):
	if enemy.is_dead: return
	
	var direction = position_to_search - enemy.global_position
	if direction.length() > 10:
		enemy.move_to_direction(direction.normalized())
		if animation_player.has_animation('walk'):
				animation_player.play('walk')
	else:
		Transitioned.emit(self, 'EnemyIdle')

	
