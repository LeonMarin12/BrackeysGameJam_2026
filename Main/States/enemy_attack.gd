extends State
class_name EnemyAttack

@export var enemy :CharacterBody2D
@export var animation_player :AnimationPlayer

var player :CharacterBody2D

func Enter():
	player = get_tree().get_first_node_in_group('player')
	enemy.attack()
	animation_player.play('attack')
