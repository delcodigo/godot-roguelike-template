## Developed by Camilo DelCódigo
##
## Coordinates the order in which turn-based actors can act.
##
## Actors register themselves into a shared list, and the manager tracks a
## single current index that determines whose turn is active.
extends Node
class_name TurnsManager

## Shared turns manager reference used by gameplay actors.
static var instance: TurnsManager

## Registered actors in turn order.
var actors: Array[Node2D]

## Index of the actor whose turn is currently active.
var current_turn: int

## Registers this node as the shared turns manager instance.
func _init() -> void:
	instance = self

## Initializes the actor list and starts turn order at the first actor.
func _ready() -> void:
	actors = []
	current_turn = 0

## Adds an actor to the turn order if it is not already registered.
func register_actor(actor: Node2D) -> void:
	if actors.find(actor) == -1:
		actors.push_back(actor)

## Removes an actor from the turn order if it is currently registered.
func remove_actor(actor: Node2D) -> void:
	var index: int = actors.find(actor)
	if index != -1:
		actors.remove_at(index)

## Returns whether the given actor owns the current turn.
func is_my_turn(actor: Node2D) -> bool:
	return actors[current_turn] == actor

## Advances the active turn to the next registered actor.
func next_turn() -> void:
	current_turn = (current_turn + 1) % actors.size()
