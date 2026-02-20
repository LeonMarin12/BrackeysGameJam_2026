extends Node2D

const INTERACT_RADIUS := 24.0

var _label: Label
var _player_inside: bool = false
var _used: bool = false


func _ready() -> void:
	var visual := ColorRect.new()
	visual.size = Vector2(10, 10)
	visual.position = Vector2(-5, -5)
	visual.color = Color(0.4, 0.7, 1.0, 0.9)
	add_child(visual)

	_label = Label.new()
	_label.text = "E to pray"
	_label.position = Vector2(-28, -22)
	_label.visible = false
	add_child(_label)


func _process(_delta: float) -> void:
	if _used:
		return
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	_player_inside = global_position.distance_to(player.global_position) < INTERACT_RADIUS
	_label.visible = _player_inside


func _unhandled_input(event: InputEvent) -> void:
	if _used or not _player_inside:
		return
	if event.is_action_pressed("interact"):
		_used = true
		_label.visible = false
		_show_choice()


func _show_choice() -> void:
	var canvas := CanvasLayer.new()
	get_tree().root.add_child(canvas)

	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.7)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(bg)

	var panel := VBoxContainer.new()
	panel.anchor_left   = 0.5
	panel.anchor_right  = 0.5
	panel.anchor_top    = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left   = -100.0
	panel.offset_right  =  100.0
	panel.offset_top    =  -60.0
	panel.offset_bottom =   60.0
	canvas.add_child(panel)

	var title := Label.new()
	title.text = "Choose a blessing:"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(title)

	var heal_btn := Button.new()
	heal_btn.text = "Restore Health"
	heal_btn.pressed.connect(_on_bless.bind(canvas, "health"))
	panel.add_child(heal_btn)

	var sanity_btn := Button.new()
	sanity_btn.text = "Restore Sanity"
	sanity_btn.pressed.connect(_on_bless.bind(canvas, "sanity"))
	panel.add_child(sanity_btn)


func _on_bless(canvas: CanvasLayer, kind: String) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		if kind == "health":
			player.restore_health(999)
		else:
			player.restore_sanity(999)
	canvas.queue_free()
	queue_free()
