## Developed by Camilo DelCódigo
##
## Turn-based player controller for keyboard and click-to-move input.
##
## The player only acts on its assigned turn. Keyboard input attempts a single
## tile step immediately, while left-click movement stores an A* path and then
## advances along that path one tile per player turn until the queue is empty.
extends Node2D
class_name Player

var _key_delay: float = 0
var _path: Array[Vector2] = []

@export var key_delay_seconds: float = 0.05 # Time after a keypress during which input is ignored, to prevent accidental double moves.

func _ready() -> void:
	TurnsManager.instance.register_actor(self)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			var target: Vector2 = get_canvas_transform().affine_inverse() * mouse_event.position
			var path: Array[Vector2] = Map.instance.pathfinding.find_path(position, target)
			if path.size() > 1:
				_path = path.slice(1)

func process_path() -> void:
	if _path.is_empty():
		return

	position = _path[0]
	_path.remove_at(0)
	_key_delay = key_delay_seconds

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
	
	if Input.is_action_pressed("upright"):
		hor = 1
		ver = -1
	elif Input.is_action_pressed("downright"):
		hor = 1
		ver = 1
	elif Input.is_action_pressed("downleft"):
		hor = -1
		ver = 1
	elif Input.is_action_pressed("upleft"):
		hor = -1
		ver = -1
	
	if hor != 0 and ver != 0:
		if not Map.instance.is_solid(position.x + hor * Config.tile_size.x, position.y) \
		and not Map.instance.is_solid(position.x, position.y + ver * Config.tile_size.y) \
		and not Map.instance.is_solid(position.x + hor * Config.tile_size.x, position.y + ver * Config.tile_size.y):
			position.x += hor * Config.tile_size.x
			position.y += ver * Config.tile_size.y
		_key_delay = key_delay_seconds
		return true
	
	return false

func _process(delta: float) -> void:
	if (_key_delay > 0):
		_key_delay -= delta
		return
	
	if not TurnsManager.instance.is_my_turn(self):
		return
	
	if not _path.is_empty():
		process_path()
		TurnsManager.instance.next_turn()
		return
	
	if process_movement():
		TurnsManager.instance.next_turn()
