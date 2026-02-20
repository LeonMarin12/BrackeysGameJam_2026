extends CanvasLayer


func _ready() -> void:
	layer = 20
	TruthManager.winstreak = 0
	_build()


func _build() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Fade in
	var tween := create_tween()
	tween.tween_property(bg, "color", Color(0.0, 0.0, 0.0, 0.85), 1.0)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "YOU DIED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.modulate = Color(0.85, 0.15, 0.15)
	vbox.add_child(title)

	var floor_label := Label.new()
	floor_label.text = "Reached floor %d" % TruthManager.current_floor
	floor_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(floor_label)

	var btn := Button.new()
	btn.text = "Return to Hub"
	btn.pressed.connect(_return_to_hub)
	vbox.add_child(btn)

	# Auto-return after 5 seconds
	get_tree().create_timer(5.0).timeout.connect(_return_to_hub)


var _returning := false

func _return_to_hub() -> void:
	if _returning:
		return
	_returning = true
	queue_free()
	TruthManager.return_to_hub()
