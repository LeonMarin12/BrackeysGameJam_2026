extends Node2D

const SPEED      := 180.0
const LIFETIME   := 3.0
const HIT_RADIUS := 6.0
const HIT_DAMAGE := 15.0

var _life: float = LIFETIME


func _ready() -> void:
	var rect := ColorRect.new()
	rect.size = Vector2(6, 6)
	rect.position = Vector2(-3, -3)
	rect.color = Color(1.0, 0.5, 0.1)
	add_child(rect)


func _process(delta: float) -> void:
	position += Vector2.RIGHT.rotated(rotation) * SPEED * delta

	_life -= delta
	if _life <= 0.0:
		queue_free()
		return

	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	if global_position.distance_to(player.global_position) < HIT_RADIUS:
		if not player.is_dead:
			player.take_damage(HIT_DAMAGE)
		queue_free()
