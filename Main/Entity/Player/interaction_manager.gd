extends Node2D

@export var player : CharacterBody2D
@export var outline_shader :Shader

@onready var sound_manger = %SoundManger

var bodies_in_area : Array = []
var selected_body = null
var previous_selected_body = null


func _process(_delta):
	if Input.is_action_just_pressed('interact'):
		if selected_body is Pickup:
			_pick_item(selected_body.pickup_name, selected_body.value)


func _pick_item(pickup_name, value):
	match pickup_name:
		'healing':
			if !player.restore_health(value): return
		'sanity':
			if !player.restore_sanity(value): return
		'ammo':
			if !player.restore_ammo(value): return
	selected_body.disappear()
	
	sound_manger.play('PickItem')


func _apply_outline(body):
	if not outline_shader:
		return
	
	var sprite = null
	
	# Verificar si el body es un Sprite2D
	if body is Sprite2D:
		sprite = body
	# O si tiene un hijo Sprite2D
	else:
		for child in body.get_children():
			if child is Sprite2D:
				sprite = child
				break
	
	if sprite and sprite.material == null:
		var shader_material = ShaderMaterial.new()
		shader_material.shader = outline_shader
		shader_material.set_shader_parameter("line_color", Color.WHITE)
		shader_material.set_shader_parameter("line_thickness", 1.0)
		sprite.material = shader_material


func _remove_outline(body):
	if not body:
		return
	
	var sprite = null
	
	# Verificar si el body es un Sprite2D
	if body is Sprite2D:
		sprite = body
	# O si tiene un hijo Sprite2D
	else:
		for child in body.get_children():
			if child is Sprite2D:
				sprite = child
				break
	
	if sprite:
		sprite.material = null


func _on_interaction_area_2d_body_entered(body):
	if not bodies_in_area.has(body):
		bodies_in_area.append(body)
		
		# Remover outline del anterior selected_body
		if selected_body:
			_remove_outline(selected_body)
		
		previous_selected_body = selected_body
		selected_body = body
		
		# Aplicar outline al nuevo selected_body
		_apply_outline(selected_body)


func _on_interaction_area_2d_body_exited(body):
	if bodies_in_area.has(body):
		bodies_in_area.erase(body)
		
		# Si el body que sale era el seleccionado, quitarle el outline
		if body == selected_body:
			_remove_outline(selected_body)
		
		# Actualizar selected_body si la lista no está vacía
		if bodies_in_area.size() > 0:
			previous_selected_body = selected_body
			selected_body = bodies_in_area[-1]
			
			# Aplicar outline al nuevo selected_body
			_apply_outline(selected_body)
		else:
			previous_selected_body = selected_body
			selected_body = null
