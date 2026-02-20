extends Node2D

@export var player_scene: PackedScene

@onready var player_spawn: Marker2D = $PlayerSpawn


func _ready() -> void:
	_spawn_player()


func _spawn_player() -> void:
	if player_scene == null:
		push_warning("Hub: assign player_scene in the Inspector.")
		return

	var player := player_scene.instantiate()
	add_child(player)

	if player_spawn != null:
		player.global_position = player_spawn.global_position

	var light := player.find_child("PointLight2D", true, false)
	if light:
		light.enabled = false

	var sanity_mgr := player.find_child("SanityManager", true, false)
	if sanity_mgr:
		sanity_mgr.enabled = false
