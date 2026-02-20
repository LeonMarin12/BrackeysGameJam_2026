extends Node2D

var sounds = {}

func _ready():
	for child in get_children():
		if child is AudioStreamPlayer2D:
			sounds[child.name.to_lower()] = child

func play(sound_name: String):
	sound_name = sound_name.to_lower()
	if sounds.has(sound_name):
		sounds[sound_name].play()
	else: 
		print('sound not found')
