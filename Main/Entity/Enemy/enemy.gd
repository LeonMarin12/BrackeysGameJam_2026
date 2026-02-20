extends CharacterBody2D
class_name Enemy

enum SpecialType { NONE, ELITE, RANGED, EXPLOSIVE, FAST }
@export var special_type: SpecialType = SpecialType.NONE

const EnemyBulletScript = preload('uid://bcr5icimgq8vk')
const RANGED_INTERVAL   = 2.5
const RANGED_RANGE      = 160.0
const EXPLODE_RADIUS    = 70.0
const EXPLODE_DAMAGE    = 40.0

@onready var entity_detector = %EntityDetectorModule
@onready var state_machine = %StateMachine
@onready var attack_cooldown_timer = %AttackCooldownTimer
@onready var sprite = $Sprite2D
@onready var sound_manager = %SoundManager


@export_category('Scenes')
@export_range(0.0, 1.0) var drop_chance: float = 0.4

@export_category('Statistics')
@export var max_life :float = 90.0
@export var move_speed :float = 50.0
@export var distance_to_attack :float = 20.0
@export var attack_damage := 10.0
@export var attack_cooldown :float = 1.0
@export var attack_push_force :float = 10.0
@export_range(0, 1) var push_resistence :float = 0.3

var life = max_life
var can_attack := true
var is_being_pushed := false
var _ranged_timer: float = 0.0
var _base_modulate: Color = Color.WHITE
var _dying: bool = false
var is_dead := false


func _ready():
	entity_detector.player_detected_with_los.connect(_on_player_detected_with_los)
	entity_detector.player_hid_behind_wall.connect(_on_player_hid_behind_wall)

	match special_type:
		SpecialType.ELITE:
			scale *= 2.0;  max_life *= 3.0;  life = max_life
			attack_damage *= 2.0;  distance_to_attack *= 2.0
			sprite.modulate = Color(1.0, 0.4, 0.4)
		SpecialType.RANGED:
			scale *= 1.5
			sprite.modulate = Color(0.9, 0.9, 0.2)
		SpecialType.EXPLOSIVE:
			scale *= 1.5;  max_life *= 1.5;  life = max_life
			sprite.modulate = Color(1.0, 0.55, 0.1)
		SpecialType.FAST:
			scale *= 0.8;  move_speed *= 3.0;  attack_cooldown *= 0.4
			sprite.modulate = Color(0.6, 0.2, 1.0)

	_base_modulate = sprite.modulate


func _physics_process(delta):
	if is_dead: return

	# Aplicar fricción al impulso
	if is_being_pushed:
		velocity = velocity.lerp(Vector2.ZERO, push_resistence)
		if velocity.length() < 5:
			velocity = Vector2.ZERO
			is_being_pushed = false
	move_and_slide()

	if special_type == SpecialType.RANGED:
		_handle_ranged(delta)


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
	
	sound_manager.play('TakeDamage')
	
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", _base_modulate, 0.1)

	if life <= 0:
		die()


func take_impulse(push_force, direction):
	velocity = push_force * direction * (1 - push_resistence) * 10
	is_being_pushed = true


func drop_loot() -> void:
	var scene: PackedScene = GlobalVariables.get_random_pickup()
	if scene == null:
		return
	var loot := scene.instantiate()
	loot.global_position = global_position
	get_tree().root.call_deferred("add_child", loot)


func die() -> void:
	if _dying:
		return
	_dying = true
	if special_type == SpecialType.EXPLOSIVE:
		_explode()
		if randf() < drop_chance:
			drop_loot()
		return
	if randf() < drop_chance:
		is_dead = true
	drop_loot()
	
	queue_free()
	#$AnimationPlayer.play('death')


func _handle_ranged(delta: float) -> void:
	_ranged_timer -= delta
	if _ranged_timer > 0.0:
		return
	var player := get_tree().get_first_node_in_group("player")
	if player == null or player.is_dead:
		return
	if global_position.distance_to(player.global_position) > RANGED_RANGE:
		return
	_ranged_timer = RANGED_INTERVAL
	var bullet := EnemyBulletScript.new()
	get_tree().root.add_child(bullet)
	bullet.global_position = global_position
	bullet.rotation = global_position.angle_to_point(player.global_position)


func _explode() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player and not player.is_dead:
		if global_position.distance_to(player.global_position) < EXPLODE_RADIUS:
			player.take_damage(EXPLODE_DAMAGE)
	var tween := create_tween()
	tween.tween_property(self, "scale", scale * 2.5, 0.15)
	tween.tween_callback(queue_free)


func _on_attack_cooldown_timer_timeout():
	can_attack = true


func _on_animation_player_animation_finished(anim_name):
	if anim_name == 'attack' or anim_name == 'take_damage':
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
