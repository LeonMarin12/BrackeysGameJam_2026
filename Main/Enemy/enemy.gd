extends CharacterBody2D

@onready var entity_detector = %EntityDetectorModule
@onready var state_machine = %StateMachine
@onready var attack_cooldown_timer = %AttackCooldownTimer

@export_category('Scenes')
@export var loot_scene :PackedScene

@export_category('Statistics')
@export var life :float = 90.0
@export var move_speed :float = 50.0
@export var distance_to_attack :float = 20.0
@export var attack_damage := 10.0
@export var attack_cooldown :float = 1.0
@export var attack_push_force :float = 10.0
@export_range(0, 1) var push_resistence :float = 0.3


var can_attack := true
var is_being_pushed := false


func _ready():
	
	# Conectar señales del detector de entidades
	entity_detector.player_detected_with_los.connect(_on_player_detected_with_los)
	entity_detector.player_hid_behind_wall.connect(_on_player_hid_behind_wall)


func _physics_process(delta):
	# Aplicar fricción al impulso
	if is_being_pushed:
		velocity = velocity.lerp(Vector2.ZERO, push_resistence)
		# Detener el empuje cuando la velocidad es muy baja
		if velocity.length() < 5:
			velocity = Vector2.ZERO
			is_being_pushed = false
	
	move_and_slide()


func move_to_direction(move_direction):
	if not is_being_pushed:
		velocity = move_direction * move_speed


func attack():
	if can_attack:
		attack_cooldown_timer.start(attack_cooldown)
		can_attack = false


func take_damage(damage :float = 1.0):
	life -= damage
	DamageNumbers.display_number(damage, global_position)
	
	if life <= 0:
		die()


func take_impulse(push_force, direction):
	velocity = push_force * direction * (1 - push_resistence) * 10
	is_being_pushed = true


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
		var player = get_tree().get_first_node_in_group('player')
		var direction = player.global_position - global_position
		body.take_impulse(attack_push_force, direction)
