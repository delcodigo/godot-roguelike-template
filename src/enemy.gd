## Developed by Camilo DelCódigo
##
## Represents a turn-based actor that can wander randomly across the map.
##
## On its turn, the enemy optionally chooses a random adjacent offset and moves
## there if the target tile is not solid. The turn always advances after the
## enemy processes its behavior, even if it stays in place.
extends Node2D
class_name Enemy

## Enables the default wandering behavior during this enemy's turn.
@export var is_randomly_wandering: bool = true

## Registers the enemy as a turn actor when the node enters the scene.
func _ready() -> void:
	TurnsManager.instance.register_actor(self)

## Processes this enemy's movement behavior for the current turn.
##
## When wandering is enabled, the enemy picks a random offset in the range
## `-1..1` for each axis and only moves if the destination tile is walkable.
func process_movement() -> void:
	if is_randomly_wandering:
		var dx: int = randi() % 3 - 1
		var dy: int = randi() % 3 - 1

		if dx != 0 or dy != 0:
			if not Map.instance.is_solid(position.x + dx * Config.tile_size.x, position.y + dy * Config.tile_size.y):
				position.x += dx * Config.tile_size.x
				position.y += dy * Config.tile_size.y
		

## Runs the enemy only on its assigned turn, then advances turn order.
func _process(_delta: float) -> void:
	if not TurnsManager.instance.is_my_turn(self):
		return
	
	process_movement()
	TurnsManager.instance.next_turn()
