extends CharacterBody2D

@onready var animated_sprite = %AnimatedSprite2D

@export var loot_scene :PackedScene

var life :float = 3


func _ready():
	animated_sprite.play('idle')


func take_damage(damage :float = 1.0):
	life -= damage
	if life <= 0:
		die()


func drop_loot():
	var loot =  loot_scene.instantiate()
	loot.global_position = global_position
	get_tree().root.call_deferred("add_child", loot)


func die():
	drop_loot()
	queue_free()
