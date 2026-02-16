extends Node2D

@export var player_scene: PackedScene
@export var enemy_scene:  PackedScene
@export var drop_scene:   PackedScene

const TILE_SIZE       := 16
const ENEMIES_PER_ROOM_MIN := 1
const ENEMIES_PER_ROOM_MAX := 3

@onready var _generator: Node = $DungeonGenerator

func _ready() -> void:
	_spawn_player()
	_spawn_enemies()

func _spawn_player() -> void:
	if player_scene == null:
		push_warning("World: assign player_scene in the Inspector.")
		return

	if _generator.rooms.is_empty():
		push_warning("World: dungeon has no rooms.")
		return

	var first_room: Rect2i = _generator.rooms[0]
	var centre := first_room.position + first_room.size / 2

	var player := player_scene.instantiate()
	add_child(player)
	player.global_position = Vector2(centre.x * TILE_SIZE, centre.y * TILE_SIZE)

func _spawn_enemies() -> void:
	if enemy_scene == null:
		return

	var rooms: Array[Rect2i] = _generator.rooms

	for i in range(1, rooms.size()):
		var room := rooms[i]
		var count := randi_range(ENEMIES_PER_ROOM_MIN, ENEMIES_PER_ROOM_MAX)

		for _j in range(count):
			var enemy := enemy_scene.instantiate()

			if drop_scene != null and enemy.get("loot_scene") != null:
				enemy.loot_scene = drop_scene

			add_child(enemy)

			var tx := randi_range(room.position.x + 1, room.end.x - 2)
			var ty := randi_range(room.position.y + 1, room.end.y - 2)
			enemy.global_position = Vector2(tx * TILE_SIZE, ty * TILE_SIZE)
