extends CanvasLayer

signal closed

const CaseSolvedScript = preload("res://Main/Hub/TheoryBoard/case_solved.gd")

var _submitted: bool = false
var _truth_buttons: Array = []
var _result_label: Label = null


func _ready() -> void:
	layer = 10
	_build_ui()


func _build_ui() -> void:
	# Dark overlay
	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.80)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Centered root
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	# Main panel
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(520, 420)
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	# Title
	var title := Label.new()
	title.text = "CASE FILE — SUBMIT THEORY"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title)

	# No-truth guard
	if TruthManager.current_truth == null:
		var warn := Label.new()
		warn.text = "No active investigation.\nEnter the dungeon first."
		warn.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(warn)
		_add_close_button(vbox)
		return

	var subtitle := Label.new()
	subtitle.text = "What supernatural force is causing this dungeon?"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(subtitle)

	vbox.add_child(HSeparator.new())

	# 2-column grid of truth buttons
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	vbox.add_child(grid)

	for truth in TruthManager.get_all_truths():
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(220, 56)
		btn.text = truth.truth_name
		btn.tooltip_text = truth.description
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.pressed.connect(_on_theory_submitted.bind(truth.type))
		grid.add_child(btn)
		_truth_buttons.append(btn)

	vbox.add_child(HSeparator.new())

	# Result label (hidden until submission)
	_result_label = Label.new()
	_result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_label.add_theme_font_size_override("font_size", 16)
	_result_label.visible = false
	_result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_result_label)

	_add_close_button(vbox)


func _add_close_button(parent: Control) -> void:
	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.pressed.connect(_close)
	parent.add_child(close_btn)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_close()


func _on_theory_submitted(truth_type: int) -> void:
	if _submitted:
		return
	_submitted = true

	for btn in _truth_buttons:
		btn.disabled = true

	var correct := TruthManager.submit_theory(truth_type)

	if correct:
		var solved: CanvasLayer = CaseSolvedScript.new()
		solved.truth_name = TruthManager.current_truth.truth_name
		solved.truth_description = TruthManager.current_truth.description
		get_tree().root.add_child(solved)
		_close()
	else:
		_result_label.visible = true
		_result_label.text = "Wrong. The investigation continues... Streak reset."
		_result_label.modulate = Color(1.0, 0.4, 0.4)
		get_tree().create_timer(2.5).timeout.connect(_close)


func _close() -> void:
	emit_signal("closed")
	queue_free()
