## Developed by Camilo DelCódigo
##
## Provides tile-based collision queries for world positions.
##
## This node exposes a shared instance so other gameplay scripts can ask
## whether a world-space position is occupied by a tile in this layer.
extends TileMapLayer
class_name Map

## Shared map reference used by gameplay systems such as Player.
static var instance: Map

## Registers this node as the shared map instance.
func _init() -> void:
	instance = self

## Returns whether the given world-space position lands on an occupied tile.
##
## The world coordinates are converted into tile coordinates using
## Config.tile_size before querying this tilemap layer.
func is_solid(world_x: float, world_y: float) -> bool:
	var tile_position: Vector2i = Vector2i(int(world_x / Config.tile_size.x), int(world_y / Config.tile_size.y))
	var tile_data: TileData = get_cell_tile_data(tile_position)
	return tile_data != null
