extends Node

var healing_pickup_scene: PackedScene = preload("res://Main/Pickup/healing_pickup.tscn")
var sanity_pickup_scene:  PackedScene = preload("res://Main/Pickup/sanity_pickup.tscn")
var ammo_pickup_scene:    PackedScene = preload("res://Main/Pickup/ammo_pickup.tscn")


func get_random_pickup() -> PackedScene:
	var available: Array[PackedScene] = [
		healing_pickup_scene,
		sanity_pickup_scene,
		ammo_pickup_scene,
	]
	return available[randi() % available.size()]
