## Shared A* helper for tile-by-tile movement across the map.
##
## The grid is rebuilt from the map's used tile region, marking every occupied
## tile as solid. The player uses it for left-click movement, then advances
## along the resulting path one tile on each of its turns.
class_name Pathfinding

var _map: Map
var _astar: AStarGrid2D

func _init(map: Map) -> void:
	_map = map
	_astar = AStarGrid2D.new()
	_astar.cell_size = Vector2(Config.tile_size)
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE

func update(region: Rect2i) -> void:
	_astar.region = region
	_astar.update()
	for x: int in range(region.position.x, region.end.x):
		for y: int in range(region.position.y, region.end.y):
			var id: Vector2i = Vector2i(x, y)
			_astar.set_point_solid(id, _map.get_cell_tile_data(id) != null)

func _is_out_of_bounds(tile: Vector2i) -> bool:
	return tile.x < 0 or tile.y < 0 or tile.x >= _map.get_used_rect().size.x or tile.y >= _map.get_used_rect().size.y

func find_path(from_world: Vector2, to_world: Vector2) -> Array[Vector2]:
	var from_tile: Vector2i = Vector2i(floori(from_world.x / Config.tile_size.x), floori(from_world.y / Config.tile_size.y))
	var to_tile: Vector2i = Vector2i(floori(to_world.x / Config.tile_size.x), floori(to_world.y / Config.tile_size.y))

	if _is_out_of_bounds(from_tile) or _is_out_of_bounds(to_tile):
		return []

	var tile_path: PackedVector2Array = _astar.get_point_path(from_tile, to_tile)
	var world_path: Array[Vector2] = []
	for point: Vector2 in tile_path:
		world_path.append(Vector2(point.x, point.y))
	return world_path
