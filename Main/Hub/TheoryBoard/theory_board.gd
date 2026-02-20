extends Area2D

@onready var label: Label = $Label

const TheoryUIScript   = preload("res://Main/Hub/TheoryBoard/theory_ui.gd")
const INTERACT_RADIUS  := 20.0

var _player_inside: bool = false
var _ui_open: bool = false


func _ready() -> void:
	label.visible = false


func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	_player_inside = global_position.distance_to(player.global_position) < INTERACT_RADIUS
	label.visible = _player_inside and not _ui_open


func _unhandled_input(event: InputEvent) -> void:
	if _player_inside and not _ui_open and event.is_action_pressed("interact"):
		_open_ui()


func _open_ui() -> void:
	_ui_open = true
	var ui: CanvasLayer = TheoryUIScript.new()
	ui.closed.connect(func() -> void: _ui_open = false)
	get_tree().root.add_child(ui)
