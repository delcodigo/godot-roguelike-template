## Developed by Camilo DelCódigo
##
## Controls the player actor during its turn in the turn-based loop.
##
## The player moves exactly one tile per accepted input using the tile size
## defined in Config. Movement into solid map tiles is blocked through the
## shared Map instance. When both axes are pressed, horizontal input is
## processed before vertical input. Any directional input consumes the player's
## turn, even if the destination tile is blocked.
extends Node2D
class_name Player

## Remaining cooldown before another movement input can be accepted.
var _key_delay: float = 0

## Time in seconds between accepted movement inputs while a direction is held.
@export var key_delay_seconds: float = 0.05

## Registers the player as a turn actor when the node enters the scene.
func _ready() -> void:
	TurnsManager.instance.register_actor(self)

## Attempts to move the player by one grid cell.
##
## Returns true when directional input is present, including blocked movement
## attempts that still consume the turn. Returns false when there is no input.
func process_movement() -> bool:
	var hor: float = Input.get_axis("left", "right")
	var ver: float = Input.get_axis("up", "down")
	
	if hor != 0:
		if not Map.instance.is_solid(position.x + hor * Config.tile_size.x, position.y):
			position.x += hor * Config.tile_size.x
		_key_delay = key_delay_seconds
		return true
	elif ver != 0:
		if not Map.instance.is_solid(position.x, position.y + ver * Config.tile_size.y):
			position.y += ver * Config.tile_size.y
		_key_delay = key_delay_seconds
		return true
	
	return false

## Updates the movement cooldown and processes movement when input is allowed.
##
## The cooldown prevents held input from advancing more than one tile per
## configured delay interval. The player can only act during its assigned turn,
## and a successful input attempt advances the turn order.
func _process(delta: float) -> void:
	if (_key_delay > 0):
		_key_delay -= delta
		return
	
	if not TurnsManager.instance.is_my_turn(self):
		return
	
	if process_movement():
		TurnsManager.instance.next_turn()
