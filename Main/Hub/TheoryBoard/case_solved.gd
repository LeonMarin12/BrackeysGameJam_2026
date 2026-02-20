extends CanvasLayer

var truth_name: String = ""
var truth_description: String = ""

var _leaving := false


func _ready() -> void:
	layer = 15
	_build()


func _build() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var tween := create_tween()
	tween.tween_property(bg, "color", Color(0.0, 0.0, 0.0, 0.88), 0.8)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 18)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "CASE SOLVED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.modulate = Color(0.4, 1.0, 0.4)
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	var truth_label := Label.new()
	truth_label.text = "The truth: %s" % truth_name
	truth_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	truth_label.add_theme_font_size_override("font_size", 22)
	vbox.add_child(truth_label)

	var desc_label := Label.new()
	desc_label.text = truth_description
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.custom_minimum_size = Vector2(480, 0)
	vbox.add_child(desc_label)

	vbox.add_child(HSeparator.new())

	var streak_label := Label.new()
	streak_label.text = "Streak: %d" % TruthManager.winstreak
	streak_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(streak_label)

	var noise_pct := int(TruthManager.get_noise_level() * 100)
	var noise_label := Label.new()
	noise_label.text = "Interference next run: %d%%" % noise_pct
	noise_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	noise_label.modulate = Color(1.0, 0.7, 0.3) if noise_pct > 0 else Color.WHITE
	vbox.add_child(noise_label)

	var btn := Button.new()
	btn.text = "New Investigation"
	btn.pressed.connect(_start_new)
	vbox.add_child(btn)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_start_new()


func _start_new() -> void:
	if _leaving:
		return
	_leaving = true
	queue_free()
	TruthManager.enter_dungeon()
