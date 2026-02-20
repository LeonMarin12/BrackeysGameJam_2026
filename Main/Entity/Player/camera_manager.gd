extends Camera2D

@export var mouse_influence: float = 0.2
@export var smoothness: float = 1.0


#Camera shake variables
var trauma = 0.0  # Rango de 0.0 a 1.0
var max_offset = Vector2(100, 75)  # Máximo movimiento horizontal/vertical
var decay = 0.8  # Qué tan rápido se detiene el movimiento 


func _ready():
	GlobalEvents.shake_camera.connect(_on_shake_camera)


func _process(delta):
	var mouse_offset = (get_global_mouse_position() - get_parent().global_position) * mouse_influence
	position = position.lerp(mouse_offset, smoothness * delta)
	manage_camera_shake(delta)


func manage_camera_shake(delta):
	if trauma > 0:
		# El trauma baja gradualmente con el tiempo
		trauma = max(trauma - decay * delta, 0)
		# Usamos trauma al cuadrado para que el movimiento se sienta más natural (suave al final)
		var amount = pow(trauma, 2)
		offset.x = max_offset.x * amount * randf_range(-1, 1)
		offset.y = max_offset.y * amount * randf_range(-1, 1)
	else:
		# Resetear el offset cuando no hay trauma
		offset = Vector2.ZERO


func _on_shake_camera(force, _decay = decay):
	# El trauma toma el valor más alto entre el actual y el nuevo
	trauma = min(max(trauma, force), 1.0)
	decay = _decay
