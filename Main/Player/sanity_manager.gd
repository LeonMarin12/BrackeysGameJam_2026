extends Node2D

@export var player: CharacterBody2D

@export var max_sanity_seconds: float = 100
@export var max_light_scale: float = 1.0
@export var min_light_scale: float = 0.2

@onready var point_light = %PointLight2D

var enabled: bool = true


func _process(delta):
	if not enabled:
		return

	var sanity_drain_rate = player.max_sanity / max_sanity_seconds
	player.sanity -= sanity_drain_rate * delta

	var sanity_clamped = max(player.sanity, 0.0)
	var sanity_percentage = sanity_clamped / player.max_sanity
	var light_scale = lerp(min_light_scale, max_light_scale, sanity_percentage)
	point_light.texture_scale = light_scale

	if player.sanity <= 0 and not player.is_dead:
		player.die()
