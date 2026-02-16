extends CanvasModulate

var dark_color = Color(0.193, 0.193, 0.193, 1.0)
var bright_color = Color(1.0, 1.0, 1.0, 1.0) 


func _ready():
	self.color = dark_color
	GlobalEvents.flash_camera.connect(_on_flash_camera)


func _on_flash_camera(flash_duration):
	var tween = create_tween()
	tween.set_parallel(false)
	tween.tween_property(self, "color", bright_color, 0.05)
	tween.tween_property(self, "color", dark_color, flash_duration).set_trans(Tween.TRANS_SINE)
