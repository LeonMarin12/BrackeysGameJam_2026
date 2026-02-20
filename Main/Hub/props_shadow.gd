extends Node2D

@export var shadow_color:  Color   = Color(0, 0, 0, 0.45)
@export var shadow_offset: Vector2 = Vector2(2, 4)

func _ready() -> void:
	var sprites: Array[Node] = find_children("*", "Sprite2D", true, false)
	for sprite in sprites:
		_add_shadow(sprite as Sprite2D)


func _add_shadow(sprite: Sprite2D) -> void:
	var shadow             := Sprite2D.new()
	shadow.texture         =  sprite.texture
	shadow.region_enabled  =  sprite.region_enabled
	shadow.region_rect     =  sprite.region_rect
	shadow.centered        =  sprite.centered
	shadow.offset          =  sprite.offset
	shadow.flip_h          =  sprite.flip_h
	shadow.flip_v          =  sprite.flip_v
	shadow.scale           =  sprite.scale
	shadow.rotation        =  sprite.rotation
	shadow.modulate        =  shadow_color
	# Render at absolute z=0 — above floor, below props (PropsLayer z=1)
	shadow.z_as_relative   =  false
	shadow.z_index         =  1

	add_child(shadow)
	move_child(shadow, 0)
	# Set position after adding to tree so global_position is valid
	shadow.global_position =  sprite.global_position + shadow_offset
