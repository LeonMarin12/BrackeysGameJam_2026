extends Area2D

@onready var animation_player = %AnimationPlayer

@export var speed: float = 400.0
@export var damage: float = 30.0

var can_move :bool = true

func _process(delta):
	if can_move:
		position += Vector2.RIGHT.rotated(rotation) * speed * delta


func _on_body_entered(body):
	if body.is_in_group('enemies'):
		if body.has_method('take_damage'):
			body.take_damage(damage)
	
	disappear()


func _on_timer_timeout():
	disappear()


func disappear():
	can_move = false
	animation_player.play('disappear')
	
