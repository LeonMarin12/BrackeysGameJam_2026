extends Node2D

var velocity: Vector2 = Vector2.ZERO
var gravity: float = 980.0  # Pixeles por segundo^2
var bounce_damping: float = 0.6  # Factor de pérdida de velocidad en cada rebote (0-1)
var min_bounce_velocity: float = 50.0  # Velocidad mínima para seguir rebotando
var ground_y: float = 0.0  # Posición del suelo
var is_static: bool = false  # Si la partícula ya está estática
var bounce_param :int = 1 # Parámetro para cambiar la direccion cuando rebota contra paredes

# Variables de rotación
var rotation_speed: float = 0.0  # Velocidad angular en radianes por segundo
var rotation_damping: float = 0.95  # Factor de reducción de la rotación (0-1)
var min_rotation_speed: float = 0.1  # Velocidad mínima de rotación antes de detenerse

# Rangos de aleatoriedad
@export var velocity_x_range: Vector2 = Vector2(120.0, 170.0)  # Rango de velocidad horizontal
@export var velocity_y_range: Vector2 = Vector2(-200.0, -100.0)  # Rango de velocidad vertical
@export var rotation_speed_range: Vector2 = Vector2(5.0, 15.0)  # Rango de velocidad de rotación
@export var ground_offset_range: Vector2 = Vector2(-2.0, 2.0)  # Variación del suelo

# Configuración inicial
func initialize(start_position: Vector2, initial_velocity: Vector2, floor_position: float, initial_rotation_speed: float = 10.0, use_random: bool = true):
	position = start_position
	
	if use_random:
		# Generar valores aleatorios dentro de los rangos
		velocity.x = randf_range(velocity_x_range.x, velocity_x_range.y) * sign(initial_velocity.x)
		velocity.y = randf_range(velocity_y_range.x, velocity_y_range.y)
		rotation_speed = randf_range(rotation_speed_range.x, rotation_speed_range.y) * (1 if randf() > 0.5 else -1)
		ground_y = floor_position + randf_range(ground_offset_range.x, ground_offset_range.y)
	else:
		velocity = initial_velocity
		rotation_speed = initial_rotation_speed
		ground_y = floor_position
	
	is_static = false


func _ready():
	# Configuración por defecto si no se llama initialize
	if ground_y == 0.0:
		ground_y = position.y + 200.0

func _process(delta: float):
	if is_static:
		return
	
	# Aplicar gravedad a la velocidad vertical
	velocity.y += gravity * delta
	
	# Actualizar posición (aplicar bounce_param solo al eje X)
	position.x += velocity.x * bounce_param * delta
	position.y += velocity.y * delta
	
	# Aplicar rotación
	rotation += rotation_speed * delta
	
	# Reducir velocidad de rotación progresivamente
	rotation_speed *= rotation_damping
	
	# Detener rotación si es muy lenta
	if abs(rotation_speed) < min_rotation_speed:
		rotation_speed = 0.0
	
	# Verificar colisión con el suelo
	if position.y >= ground_y:
		position.y = ground_y
		
		# Verificar si la velocidad es suficiente para rebotar
		if abs(velocity.y) > min_bounce_velocity:
			# Rebotar: invertir velocidad vertical y aplicar amortiguación
			velocity.y = -velocity.y * bounce_damping
			# También reducir velocidad horizontal
			velocity.x *= bounce_damping
		else:
			# Detener la partícula
			velocity = Vector2.ZERO
			is_static = true
			_on_particle_stopped()

func _on_particle_stopped():
	# Callback cuando la partícula se detiene (opcional, para extender funcionalidad)
	pass


func _on_area_2d_body_entered(body):
	# Detectar si colisiona con un TileMap
	if body is TileMapLayer:
		# Invertir la dirección horizontal de movimiento
		bounce_param = -1 * bounce_param
		# Opcional: aplicar una pequeña reducción de velocidad al rebotar contra paredes
		velocity.x *= 0.8
		velocity.y *= 0.8
