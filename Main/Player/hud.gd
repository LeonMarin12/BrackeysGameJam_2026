extends CanvasLayer

var player: CharacterBody2D

var _health_bar:  ProgressBar
var _sanity_bar:  ProgressBar
var _ammo_label:  Label


func _ready() -> void:
	layer = 5
	_build()


func _build() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_TOP_LEFT)
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	margin.add_child(vbox)

	_health_bar = _make_bar("HP ", Color(0.85, 0.2, 0.2), vbox)
	_sanity_bar = _make_bar("SAN", Color(0.3, 0.5, 0.9), vbox)

	var ammo_row := HBoxContainer.new()
	vbox.add_child(ammo_row)

	var ammo_key := Label.new()
	ammo_key.text = "AMMO "
	ammo_row.add_child(ammo_key)

	_ammo_label = Label.new()
	ammo_row.add_child(_ammo_label)


func _make_bar(label_text: String, color: Color, parent: Control) -> ProgressBar:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	parent.add_child(row)

	var lbl := Label.new()
	lbl.text = label_text
	lbl.custom_minimum_size = Vector2(38, 0)
	row.add_child(lbl)

	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(100, 10)
	bar.min_value = 0.0
	bar.max_value = 1.0
	bar.show_percentage = false

	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	bar.add_theme_stylebox_override("fill", fill)

	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	bar.add_theme_stylebox_override("background", bg)

	row.add_child(bar)
	return bar


func _process(_delta: float) -> void:
	if not is_instance_valid(player):
		return

	_health_bar.value = player.health / player.max_health
	_sanity_bar.value  = player.sanity / player.max_sanity

	var wm = player.weapon_manager
	if is_instance_valid(wm):
		_ammo_label.text = "%d / %d" % [wm.bullets_in_magazine, wm.bullets_left]
