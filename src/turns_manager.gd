## Developed by Camilo DelCódigo
##
## Coordinates the order in which turn-based actors can act.
##
## Actors register themselves into a shared list, and the manager tracks a
## single current index that determines whose turn is active.
extends Node
class_name TurnsManager

static var instance: TurnsManager

var _actors: Array[Node2D]
var _current_turn: int

func _init() -> void:
	instance = self

func _ready() -> void:
	_actors = []
	_current_turn = 0

func register_actor(actor: Node2D) -> void:
	if _actors.find(actor) == -1:
		_actors.push_back(actor)

func remove_actor(actor: Node2D) -> void:
	var index: int = _actors.find(actor)
	if index != -1:
		_actors.remove_at(index)

func is_my_turn(actor: Node2D) -> bool:
	return _actors[_current_turn] == actor

func next_turn() -> void:
	_current_turn = (_current_turn + 1) % _actors.size()
