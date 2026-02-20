extends Area2D

@onready var label: Label = $Label

const INTERACT_RADIUS := 20.0

var _player_inside: bool = false


func _ready() -> void:
	label.visible = false


func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	_player_inside = global_position.distance_to(player.global_position) < INTERACT_RADIUS
	label.visible = _player_inside


func _unhandled_input(event: InputEvent) -> void:
	if _player_inside and event.is_action_pressed("interact"):
		TruthManager.enter_dungeon()
