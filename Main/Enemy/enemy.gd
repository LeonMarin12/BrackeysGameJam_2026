extends CharacterBody2D

@onready var animated_sprite = %AnimatedSprite2D
@onready var entity_detector = %EntityDetectorModule
@onready var state_machine = %StateMachine
@onready var animation_player = %AnimationPlayer
@onready var attack_cooldown_timer = %AttackCooldownTimer

@export var loot_scene :PackedScene

var life :float = 3
var move_speed :float = 40
var distance_to_attack := 20
var attack_damage := 10
var attack_cooldown :float = 1.0
var attack_push_force := 100

var can_attack := true

func _ready():
	animated_sprite.play('idle')
	
	# Conectar señales del detector de entidades
	entity_detector.player_detected_with_los.connect(_on_player_detected_with_los)
	entity_detector.player_hid_behind_wall.connect(_on_player_hid_behind_wall)


func _physics_process(delta):
	move_and_slide()


func move_to_direction(move_direction):
	velocity = move_direction * move_speed


func attack():
	if can_attack:
		animation_player.play('attack')
		attack_cooldown_timer.start(attack_cooldown)
		can_attack = false


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


func _on_attack_cooldown_timer_timeout():
	can_attack = true


func _on_animation_player_animation_finished(anim_name):
	if anim_name == 'attack':
		state_machine.transition_to('EnemyFollow')


func _on_player_detected_with_los(player: Node2D):
	state_machine.transition_to('EnemyFollow')


func _on_player_hid_behind_wall():
	state_machine.transition_to('EnemySearching')


func _on_hurt_box_body_entered(body):
	if body.is_in_group('player'):
		body.take_damage(attack_damage)
