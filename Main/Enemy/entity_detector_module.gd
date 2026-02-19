extends Node2D

@onready var entity_ray_cast = %EntityRayCast

var detected_player: Node2D = null
var has_line_of_sight: bool = false

#line of sight - signals
signal player_detected_with_los(player: Node2D)  # Player detectado con línea de visión clara
signal player_hid_behind_wall()  # Player se escondió detrás de una pared (tenía LOS)


func _physics_process(_delta):
	if detected_player and is_instance_valid(detected_player):
		# Actualizar la dirección del raycast hacia el player
		# target_position es relativo a la posición del raycast
		var to_player = detected_player.global_position - entity_ray_cast.global_position
		
		entity_ray_cast.target_position = to_player
		entity_ray_cast.force_raycast_update()
		
		# Verificar si hay un TileMap bloqueando
		var previous_los = has_line_of_sight
		
		if entity_ray_cast.is_colliding():
			var collider = entity_ray_cast.get_collider()
			# Si colisiona con un TileMapLayer (paredes), no hay línea de visión
			if collider is TileMapLayer:
				if previous_los:
					# Tenía línea de visión y ahora se escondió
					has_line_of_sight = false
					player_hid_behind_wall.emit()
				else:
					# No tenía línea de visión, sigue sin tenerla
					has_line_of_sight = false
			# Si colisiona con el player, hay línea de visión
			elif collider == detected_player:
				if not previous_los:
					# No tenía línea de visión y ahora sí
					has_line_of_sight = true
					player_detected_with_los.emit(detected_player)
				else:
					# Ya tenía línea de visión, la mantiene
					has_line_of_sight = true
			# Si colisiona con otra cosa, no hay línea de visión
			else:
				if previous_los:
					has_line_of_sight = false
					player_hid_behind_wall.emit()
				else:
					has_line_of_sight = false
		else:
			# No hay colisión entre el enemigo y el player, no debería pasar
			# pero lo tratamos como línea de visión clara
			if not previous_los:
				has_line_of_sight = true
				player_detected_with_los.emit(detected_player)
			else:
				has_line_of_sight = true


func _on_entity_detector_area_body_entered(body):
	if body.is_in_group('player'):
		detected_player = body
