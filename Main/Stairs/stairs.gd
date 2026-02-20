extends Area2D

@export var goes_to_hub: bool = false

@onready var label: Label = $Label

const INTERACT_RADIUS := 20.0

var _player_inside: bool = false
var boss_enemy: Node = null


func _ready() -> void:
	label.visible = false
	var visual := $Visual
	if goes_to_hub:
		visual.color = Color(0.3, 0.6, 1.0, 0.85)
		label.text = "E  return to hub"
	else:
		visual.color = Color(0.9, 0.75, 0.1, 0.85)
		label.text = "E  go deeper"


func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	_player_inside = global_position.distance_to(player.global_position) < INTERACT_RADIUS
	label.visible = _player_inside


func _unhandled_input(event: InputEvent) -> void:
	if _player_inside and event.is_action_pressed("interact"):
		if not goes_to_hub and boss_enemy != null and is_instance_valid(boss_enemy):
			_show_blocked()
			return
		if goes_to_hub:
			TruthManager.return_to_hub()
		else:
			TruthManager.go_deeper()


func _show_blocked() -> void:
	var old_text := label.text
	label.text = "Defeat the boss first!"
	var tween := create_tween()
	tween.tween_interval(2.0)
	tween.tween_callback(func(): label.text = old_text)
