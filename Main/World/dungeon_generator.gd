extends Node

const DUNGEON_W  := 80
const DUNGEON_H  := 60
const TILE_SIZE  := 16
const MIN_ROOM   := 5
const MAX_ROOM   := 12
const MIN_BSP    := 8
const CORRIDOR_W := 2

const SRC      := 0
const DECO_SRC := 0

@export_group("Floor")

@export var floor_tiles: Array[Vector2i] = [
	Vector2i(0, 0),
	Vector2i(1, 0),
	Vector2i(2, 0),
]
@export var spike_tile:   Vector2i = Vector2i(3, 3)
@export var spike_chance: float    = 0.04 

@export_group("Walls – Cardinals")

@export var wall_n:    Vector2i = Vector2i(10, 1)  # floor only to north
@export var wall_s:    Vector2i = Vector2i(9,  7)  # top of wall
@export var wall_e:    Vector2i = Vector2i(11, 5)  # left wall
@export var wall_w:    Vector2i = Vector2i(8, 3)  # right wall
@export var wall_none: Vector2i = Vector2i(10, 0)  # no floor neighbours 

@export_group("Walls – Two Sides")
@export var wall_ns:   Vector2i = Vector2i(0, 1)  # floor north + south 
@export var wall_ew:   Vector2i = Vector2i(2, 7)  # floor east  + west 
@export var wall_ne:   Vector2i = Vector2i(11, 1)  # floor north + east
@export var wall_nw:   Vector2i = Vector2i(8,  1)  # floor north + west
@export var wall_se:   Vector2i = Vector2i(11, 7)  # floor south + east
@export var wall_sw:   Vector2i = Vector2i(8,  7)  # floor south + west

@export_group("Walls – T-junctions")
@export var wall_t_n:  Vector2i = Vector2i(2, 5)  # floor S+E+W
@export var wall_t_s:  Vector2i = Vector2i(10, 7)  # floor N+E+W
@export var wall_t_e:  Vector2i = Vector2i(1, 3)  # floor N+S+W
@export var wall_t_w:  Vector2i = Vector2i(3, 3)  # floor N+S+E

@export_group("Walls – Cross")
@export var wall_cross:    Vector2i = Vector2i(10, 0)  # floor on all 4 sides
@export var wall_cross_bl: Vector2i = Vector2i(-1, -1) # bottom-left dark
@export var wall_cross_br: Vector2i = Vector2i(-1, -1) # bottom-right dark

@export_group("Walls – Outer Corners")

@export var wall_corner_nw: Vector2i = Vector2i(11, 3)  # top-left corner
@export var wall_corner_ne: Vector2i = Vector2i(8, 5)  # top-right corner
@export var wall_corner_sw: Vector2i = Vector2i(6, 3)  # bottom-left corner
@export var wall_corner_se: Vector2i = Vector2i(5, 3)  # bottom-right corner

@export_group("Wall Decoration")
# (-1, -1) skip
@export var deco_none:  Vector2i = Vector2i(-1, -1)
@export var deco_n:     Vector2i = Vector2i(10, 0)
@export var deco_s:     Vector2i = Vector2i(9, 6)
@export var deco_e:     Vector2i = Vector2i(11, 4)
@export var deco_w:     Vector2i = Vector2i(8, 2)
@export var deco_ns_start: Vector2i = Vector2i(0, 0)
@export var deco_ns_end:   Vector2i = Vector2i(0, 5)
@export var deco_ew_start: Vector2i = Vector2i(-1, -1)
@export var deco_ew_end:   Vector2i = Vector2i(-1, -1)
@export var deco_ne:    Vector2i = Vector2i(11, -0)
@export var deco_nw:    Vector2i = Vector2i(8, 0)
@export var deco_se:    Vector2i = Vector2i(11, 6)
@export var deco_sw:    Vector2i = Vector2i(8, 6)
@export var deco_t_n:   Vector2i = Vector2i(2, 4)
@export var deco_t_s:   Vector2i = Vector2i(10, 6)
@export var deco_t_e:   Vector2i = Vector2i(1, 2)
@export var deco_t_w:   Vector2i = Vector2i(3, 2)
@export var deco_cross:    Vector2i = Vector2i(-1, -1)
@export var deco_cross_bl: Vector2i = Vector2i(-1, -1)
@export var deco_cross_br: Vector2i = Vector2i(-1, -1)
@export var deco_corner_nw: Vector2i = Vector2i(11, 2)
@export var deco_corner_ne: Vector2i = Vector2i(8, 4)
@export var deco_corner_sw: Vector2i = Vector2i(6, 2)
@export var deco_corner_se: Vector2i = Vector2i(5, 2)

@export_group("Generation")
@export var random_seed: bool = true
@export var fixed_seed:  int  = 0

@onready var floor_layer: TileMapLayer = $"../FloorLayer"
@onready var wall_layer:  TileMapLayer = $"../WallLayer"
@onready var deco_layer:  TileMapLayer = $"../WallDecoLayer"

var _rng   := RandomNumberGenerator.new()
var rooms:  Array[Rect2i] = []
var _spawn: Marker2D = null

class BSPNode:
	var rect:     Rect2i
	var left:     BSPNode = null
	var right:    BSPNode = null
	var room:     Rect2i
	var has_room: bool = false

	func _init(r: Rect2i) -> void:
		rect = r


func _ready() -> void:
	_setup_wall_collisions()
	generate()


func generate() -> void:
	if random_seed:
		_rng.randomize()
	else:
		_rng.seed = fixed_seed

	rooms.clear()
	floor_layer.clear()
	wall_layer.clear()
	deco_layer.clear()

	if is_instance_valid(_spawn):
		_spawn.queue_free()
		_spawn = null

	var root := BSPNode.new(Rect2i(0, 0, DUNGEON_W, DUNGEON_H))
	_split(root)
	_carve_rooms(root)
	_connect(root)
	_stamp_walls()

	if rooms.size() > 0:
		_place_spawn(rooms[0])


func _split(node: BSPNode) -> void:
	var w := node.rect.size.x
	var h := node.rect.size.y

	var can_split_x := w >= MIN_BSP * 2
	var can_split_y := h >= MIN_BSP * 2

	if not can_split_x and not can_split_y:
		return

	var cut_horizontal: bool
	if can_split_x and can_split_y:
		cut_horizontal = (h > w) or (h == w and _rng.randi() % 2 == 0)
	else:
		cut_horizontal = can_split_y

	if cut_horizontal:
		var lo := MIN_BSP
		var hi := h - MIN_BSP
		if lo > hi:
			return
		var split := _rng.randi_range(lo, hi)
		node.left  = BSPNode.new(Rect2i(node.rect.position.x, node.rect.position.y,         w, split    ))
		node.right = BSPNode.new(Rect2i(node.rect.position.x, node.rect.position.y + split, w, h - split))
	else:
		var lo := MIN_BSP
		var hi := w - MIN_BSP
		if lo > hi:
			return
		var split := _rng.randi_range(lo, hi)
		node.left  = BSPNode.new(Rect2i(node.rect.position.x,         node.rect.position.y, split,     h))
		node.right = BSPNode.new(Rect2i(node.rect.position.x + split, node.rect.position.y, w - split, h))

	_split(node.left)
	_split(node.right)


func _carve_rooms(node: BSPNode) -> void:
	if node.left == null and node.right == null:
		_make_room(node)
		return
	if node.left:
		_carve_rooms(node.left)
	if node.right:
		_carve_rooms(node.right)


func _make_room(node: BSPNode) -> void:
	var max_w := mini(MAX_ROOM, node.rect.size.x - 2)
	var max_h := mini(MAX_ROOM, node.rect.size.y - 2)
	if max_w < MIN_ROOM or max_h < MIN_ROOM:
		return

	var rw := _rng.randi_range(MIN_ROOM, max_w)
	var rh := _rng.randi_range(MIN_ROOM, max_h)
	var rx := node.rect.position.x + _rng.randi_range(1, node.rect.size.x - rw - 1)
	var ry := node.rect.position.y + _rng.randi_range(1, node.rect.size.y - rh - 1)

	node.room     = Rect2i(rx, ry, rw, rh)
	node.has_room = true
	rooms.append(node.room)

	var is_spawn := rooms.size() == 1

	for x in range(rx, rx + rw):
		for y in range(ry, ry + rh):
			var atlas: Vector2i
			if not is_spawn and _rng.randf() < spike_chance:
				atlas = spike_tile
			else:
				atlas = floor_tiles[_rng.randi() % floor_tiles.size()]
			floor_layer.set_cell(Vector2i(x, y), SRC, atlas)


func _connect(node: BSPNode) -> void:
	if node.left == null or node.right == null:
		return
	_connect(node.left)
	_connect(node.right)

	var a := _subtree_center(node.left)
	var b := _subtree_center(node.right)
	if a == Vector2i(-1, -1) or b == Vector2i(-1, -1):
		return
	_dig_corridor(a, b)


func _subtree_center(node: BSPNode) -> Vector2i:
	if node.left == null and node.right == null:
		if node.has_room:
			return node.room.position + node.room.size / 2
		return Vector2i(-1, -1)
	var lc := Vector2i(-1, -1)
	var rc := Vector2i(-1, -1)
	if node.left:
		lc = _subtree_center(node.left)
	if node.right:
		rc = _subtree_center(node.right)
	return lc if lc != Vector2i(-1, -1) else rc

func _dig_corridor(a: Vector2i, b: Vector2i) -> void:
	var cur := a
	if _rng.randi() % 2 == 0:
		while cur.x != b.x:
			_stamp_corridor(cur)
			cur.x += sign(b.x - cur.x)
		while cur.y != b.y:
			_stamp_corridor(cur)
			cur.y += sign(b.y - cur.y)
	else:
		while cur.y != b.y:
			_stamp_corridor(cur)
			cur.y += sign(b.y - cur.y)
		while cur.x != b.x:
			_stamp_corridor(cur)
			cur.x += sign(b.x - cur.x)
	_stamp_corridor(cur)   # destination block


## Stamps a CORRIDOR_W × CORRIDOR_W floor block at pos using the base floor tile.
func _stamp_corridor(pos: Vector2i) -> void:
	for dx in range(CORRIDOR_W):
		for dy in range(CORRIDOR_W):
			floor_layer.set_cell(pos + Vector2i(dx, dy), SRC, floor_tiles[0])

func _stamp_walls() -> void:
	var floor_cells := floor_layer.get_used_cells()
	var floor_set: Dictionary = {}
	for c: Vector2i in floor_cells:
		floor_set[c] = true

	for c: Vector2i in floor_cells:
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				if dx == 0 and dy == 0:
					continue
				var nb := Vector2i(c.x + dx, c.y + dy)
				if not floor_set.has(nb):
					floor_layer.set_cell(nb, SRC, floor_tiles[0])
					wall_layer.set_cell(nb, SRC, _pick_wall_atlas(nb, floor_set))
					var nb_n := floor_set.has(nb + Vector2i( 0, -1))
					var nb_s := floor_set.has(nb + Vector2i( 0,  1))
					var nb_e := floor_set.has(nb + Vector2i( 1,  0))
					var nb_w := floor_set.has(nb + Vector2i(-1,  0))
					if nb_n and nb_s:
						if deco_ns_start != Vector2i(-1, -1):
							deco_layer.set_cell(nb + Vector2i( 0, -1), DECO_SRC, deco_ns_start)
						if deco_ns_end != Vector2i(-1, -1):
							deco_layer.set_cell(nb + Vector2i( 0,  1), DECO_SRC, deco_ns_end)
					elif nb_e and nb_w:
						if deco_ew_start != Vector2i(-1, -1):
							deco_layer.set_cell(nb + Vector2i(-1,  0), DECO_SRC, deco_ew_start)
						if deco_ew_end != Vector2i(-1, -1):
							deco_layer.set_cell(nb + Vector2i( 1,  0), DECO_SRC, deco_ew_end)
					else:
						var deco := _pick_deco_atlas(nb, floor_set)
						if deco != Vector2i(-1, -1):
							deco_layer.set_cell(nb + Vector2i(0, -1), DECO_SRC, deco)


## Bit layout N=3  S=2  E=1  W=0
func _pick_wall_atlas(pos: Vector2i, floor_set: Dictionary) -> Vector2i:
	var n := int(floor_set.has(pos + Vector2i( 0, -1)))
	var s := int(floor_set.has(pos + Vector2i( 0,  1)))
	var e := int(floor_set.has(pos + Vector2i( 1,  0)))
	var w := int(floor_set.has(pos + Vector2i(-1,  0)))
	match (n << 3) | (s << 2) | (e << 1) | w:
		0b0001: return wall_w       # W
		0b0010: return wall_e       # E
		0b0011: return wall_ew      # E+W
		0b0100: return wall_s       # S
		0b0101: return wall_sw      # S+W
		0b0110: return wall_se      # S+E
		0b0111: return wall_t_n     # S+E+W  (T open north)
		0b1000: return wall_n       # N
		0b1001: return wall_nw      # N+W
		0b1010: return wall_ne      # N+E
		0b1011: return wall_t_s     # N+E+W  (T open south)
		0b1100: return wall_ns      # N+S
		0b1101: return wall_t_w     # N+S+W  (T open west)
		0b1110: return wall_t_e     # N+S+E  (T open east)
		0b1111:
			if not floor_set.has(pos + Vector2i(-1,  1)):
				return wall_cross_bl if wall_cross_bl != Vector2i(-1, -1) else wall_cross
			if not floor_set.has(pos + Vector2i( 1,  1)):
				return wall_cross_br if wall_cross_br != Vector2i(-1, -1) else wall_cross
			return wall_cross
		_:
			if floor_set.has(pos + Vector2i( 1,  1)): return wall_corner_nw
			if floor_set.has(pos + Vector2i(-1,  1)): return wall_corner_ne
			if floor_set.has(pos + Vector2i( 1, -1)): return wall_corner_sw
			if floor_set.has(pos + Vector2i(-1, -1)): return wall_corner_se
			return wall_none

func _pick_deco_atlas(pos: Vector2i, floor_set: Dictionary) -> Vector2i:
	var n := int(floor_set.has(pos + Vector2i( 0, -1)))
	var s := int(floor_set.has(pos + Vector2i( 0,  1)))
	var e := int(floor_set.has(pos + Vector2i( 1,  0)))
	var w := int(floor_set.has(pos + Vector2i(-1,  0)))
	match (n << 3) | (s << 2) | (e << 1) | w:
		0b0001: return deco_w
		0b0010: return deco_e
		0b0011: return Vector2i(-1, -1)
		0b0100: return deco_s
		0b0101: return deco_sw
		0b0110: return deco_se
		0b0111: return deco_t_n
		0b1000: return deco_n
		0b1001: return deco_nw
		0b1010: return deco_ne
		0b1011: return deco_t_s
		0b1100: return Vector2i(-1, -1)
		0b1101: return deco_t_w
		0b1110: return deco_t_e
		0b1111:
			if not floor_set.has(pos + Vector2i(-1,  1)):
				return deco_cross_bl if deco_cross_bl != Vector2i(-1, -1) else deco_cross
			if not floor_set.has(pos + Vector2i( 1,  1)):
				return deco_cross_br if deco_cross_br != Vector2i(-1, -1) else deco_cross
			return deco_cross
		_:
			if floor_set.has(pos + Vector2i( 1,  1)): return deco_corner_nw
			if floor_set.has(pos + Vector2i(-1,  1)): return deco_corner_ne
			if floor_set.has(pos + Vector2i( 1, -1)): return deco_corner_sw
			if floor_set.has(pos + Vector2i(-1, -1)): return deco_corner_se
			return deco_none

func _place_spawn(room: Rect2i) -> void:
	_spawn          = Marker2D.new()
	_spawn.name     = "SpawnPoint"
	var centre      := room.position + room.size / 2
	_spawn.position = Vector2(centre.x * TILE_SIZE, centre.y * TILE_SIZE)
	get_parent().add_child(_spawn)


func _setup_wall_collisions() -> void:
	var ts: TileSet = wall_layer.tile_set
	if ts == null:
		return

	if ts.get_physics_layers_count() == 0:
		ts.add_physics_layer()
		ts.set_physics_layer_collision_layer(0, 8)
		ts.set_physics_layer_collision_mask(0, 0)

	var source := ts.get_source(SRC) as TileSetAtlasSource
	if source == null:
		return

	var half := TILE_SIZE / 2.0
	var poly  := PackedVector2Array([
		Vector2(-half, -half),
		Vector2( half, -half),
		Vector2( half,  half),
		Vector2(-half,  half),
	])

	for coord in [
		wall_none, wall_n, wall_s, wall_e, wall_w,
		wall_ns, wall_ew, wall_ne, wall_nw, wall_se, wall_sw,
		wall_t_n, wall_t_s, wall_t_e, wall_t_w,
		wall_cross, wall_cross_bl, wall_cross_br,
	]:
		if not source.has_tile(coord):
			continue
		var td: TileData = source.get_tile_data(coord, 0)
		if td == null or td.get_collision_polygons_count(0) > 0:
			continue
		td.add_collision_polygon(0)
		td.set_collision_polygon_points(0, 0, poly)
