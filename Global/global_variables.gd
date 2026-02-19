extends Node

@export var healing_pickup_scene :PackedScene
@export var sanity_pickup_scene :PackedScene
@export var ammo_pickup_scene :PackedScene


var pickup_list :Dictionary = {
	'healing' : healing_pickup_scene,
	'sanity' : sanity_pickup_scene,
	'ammo' : ammo_pickup_scene,
}
