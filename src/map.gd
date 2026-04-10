## Developed by Camilo DelCódigo
##
## Exposes the blocking tile layer used by movement and pathfinding.
##
## This tilemap acts as the gameplay collision source: if a cell in this
## layer contains tile data, actors treat that tile as solid. The node also
## builds the shared pathfinding grid from the same occupied cells.
extends TileMapLayer
class_name Map

static var instance: Map

var pathfinding: Pathfinding

func _init() -> void:
	instance = self

func _ready() -> void:
	pathfinding = Pathfinding.new(self)
	pathfinding.update(get_used_rect())

func is_solid(world_x: float, world_y: float) -> bool:
	var tile_position: Vector2i = Vector2i(int(world_x / Config.tile_size.x), int(world_y / Config.tile_size.y))
	var tile_data: TileData = get_cell_tile_data(tile_position)
	return tile_data != null
