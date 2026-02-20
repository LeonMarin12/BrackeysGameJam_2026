extends Node2D

@export var player :CharacterBody2D

@export var max_sanity_seconds :float = 100
@export var max_light_scale :float = 1.0
@export var min_light_scale :float = 0.2

@onready var point_light = %PointLight2D

func _process(delta):
	# Calcular la tasa de descenso de sanidad por segundo
	var sanity_drain_rate = player.max_sanity / max_sanity_seconds
	
	# Reducir la sanidad basándose en el tiempo transcurrido
	player.sanity -= sanity_drain_rate * delta
	
	# Escalar la luz en función de la sanidad
	var sanity_clamped = max(player.sanity, 0.0)
	var sanity_percentage = sanity_clamped / player.max_sanity
	var light_scale = lerp(min_light_scale, max_light_scale, sanity_percentage)
	point_light.texture_scale = light_scale
	
	# Asegurar que no baje de 0
	if player.sanity <= 0:
		player.die()
		
