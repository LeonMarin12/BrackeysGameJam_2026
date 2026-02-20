extends Node2D

enum RoomType { NORMAL, TREASURE, BOSS, SHRINE }

@export var player_scene:  PackedScene
@export var undead_scenes: Array[PackedScene] = []
@export var demon_scenes:  Array[PackedScene] = []
@export var drop_scene:    PackedScene
@export var stairs_scene:  PackedScene

const TILE_SIZE            := 16
const _STAIRS_FALLBACK     := preload("res://Main/Stairs/stairs.tscn")
const ShrineScript         := preload("res://Main/World/shrine.gd")
const ENEMIES_PER_ROOM_MIN := 1
const ENEMIES_PER_ROOM_MAX := 3

@onready var _generator: Node = $DungeonGenerator

var _room_types: Array = []
var _boss_enemy: Node = null


func _ready() -> void:
	TruthManager.pick_truth()
	_spawn_player()
	_assign_room_types()
	_spawn_enemies()
	_spawn_stairs()


func _assign_room_types() -> void:
	var count: int = _generator.rooms.size()
	_room_types.resize(count)
	_room_types.fill(RoomType.NORMAL)
	if count < 3:
		return
	_room_types[count - 1] = RoomType.BOSS
	var middle := range(1, count - 1)
	middle.shuffle()
	if middle.size() > 0: _room_types[middle[0]] = RoomType.TREASURE
	if middle.size() > 1: _room_types[middle[1]] = RoomType.SHRINE


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
	var rooms: Array[Rect2i] = _generator.rooms

	for i in range(1, rooms.size()):
		match _room_types[i]:
			RoomType.NORMAL:   _spawn_normal_room(rooms[i])
			RoomType.BOSS:     _spawn_boss_room(rooms[i])
			RoomType.TREASURE: _spawn_treasure_room(rooms[i])
			RoomType.SHRINE:   _spawn_shrine_room(rooms[i])


func _spawn_normal_room(room: Rect2i) -> void:
	var count := randi_range(ENEMIES_PER_ROOM_MIN, ENEMIES_PER_ROOM_MAX)

	for _j in range(count):
		var scene := _pick_enemy_scene()
		if scene == null:
			continue

		var enemy := scene.instantiate()

		if drop_scene != null and enemy.get("loot_scene") != null:
			enemy.loot_scene = drop_scene

		var roll := randf()
		if roll < 0.04:
			enemy.special_type = Enemy.SpecialType.ELITE
		elif roll < 0.11:
			enemy.special_type = Enemy.SpecialType.RANGED
		elif roll < 0.18:
			enemy.special_type = Enemy.SpecialType.EXPLOSIVE
		elif roll < 0.25:
			enemy.special_type = Enemy.SpecialType.FAST

		add_child(enemy)

		var tx := randi_range(room.position.x + 1, room.end.x - 2)
		var ty := randi_range(room.position.y + 1, room.end.y - 2)
		enemy.global_position = Vector2(tx * TILE_SIZE, ty * TILE_SIZE)


func _spawn_boss_room(room: Rect2i) -> void:
	var scene := _pick_enemy_scene()
	if scene == null:
		return

	var enemy := scene.instantiate()
	enemy.special_type = Enemy.SpecialType.ELITE
	add_child(enemy)

	enemy.scale *= 4.0
	enemy.max_life = enemy.max_life / 3.0 * 5.0
	enemy.life = enemy.max_life

	var centre := room.position + room.size / 2
	enemy.global_position = Vector2(centre.x * TILE_SIZE, centre.y * TILE_SIZE)

	_boss_enemy = enemy


func _spawn_treasure_room(room: Rect2i) -> void:
	for _i in range(4):
		var scene := GlobalVariables.get_random_pickup()
		if scene == null:
			continue
		var pickup := scene.instantiate()
		add_child(pickup)
		var tx := randi_range(room.position.x + 1, room.end.x - 2)
		var ty := randi_range(room.position.y + 1, room.end.y - 2)
		pickup.global_position = Vector2(tx * TILE_SIZE, ty * TILE_SIZE)


func _spawn_shrine_room(room: Rect2i) -> void:
	var shrine := ShrineScript.new()
	add_child(shrine)
	var centre := room.position + room.size / 2
	shrine.global_position = Vector2(centre.x * TILE_SIZE, centre.y * TILE_SIZE)


func _spawn_stairs() -> void:
	var scene: PackedScene = stairs_scene if stairs_scene != null else _STAIRS_FALLBACK
	if _generator.rooms.size() < 2:
		return

	var rooms: Array[Rect2i] = _generator.rooms

	var hub_stairs := scene.instantiate()
	hub_stairs.goes_to_hub = true
	add_child(hub_stairs)
	var start_centre := rooms[0].position + rooms[0].size / 2
	hub_stairs.global_position = Vector2(start_centre.x * TILE_SIZE, start_centre.y * TILE_SIZE)

	var exit_stairs := scene.instantiate()
	exit_stairs.goes_to_hub = false
	add_child(exit_stairs)
	var last_centre := rooms[rooms.size() - 1].position + rooms[rooms.size() - 1].size / 2
	exit_stairs.global_position = Vector2(last_centre.x * TILE_SIZE, last_centre.y * TILE_SIZE)

	if _boss_enemy != null:
		exit_stairs.boss_enemy = _boss_enemy


func _pick_enemy_scene() -> PackedScene:
	var pool: Array[PackedScene]

	if randf() < TruthManager.effective_undead_weight():
		pool = undead_scenes if not undead_scenes.is_empty() else demon_scenes
	else:
		pool = demon_scenes if not demon_scenes.is_empty() else undead_scenes

	if pool.is_empty():
		return null

	return pool[randi() % pool.size()]
