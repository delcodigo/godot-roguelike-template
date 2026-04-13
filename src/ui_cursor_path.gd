## Developed by Camilo DelCódigo
##
## Displays a cursor mesh at the mouse position, 
## snapping to the tile grid and showing the A* path 
## from the player to the mouse when applicable.
extends Node2D

var _cursor_tile: Vector2i = Vector2i(-1, -1)

@export var player: Player

@onready var cursor_mesh: MeshInstance2D = $CursorMesh

func _ready() -> void:
	cursor_mesh.mesh = ArrayMesh.new()
	
	if not Config.enable_mouse_movement:
		get_tree().free()

func _rebuild_mesh(path: Array[Vector2]) -> void:
	var array_mesh: ArrayMesh = cursor_mesh.mesh as ArrayMesh
	array_mesh.clear_surfaces()

	var tile_w: float = Config.tile_size.x
	var tile_h: float = Config.tile_size.y

	var vertices: PackedVector3Array = PackedVector3Array()
	var indices: PackedInt32Array = PackedInt32Array()

	for i: int in range(path.size()):
		var tile_pos: Vector2 = path[i]
		var x: float = tile_pos.x
		var y: float = tile_pos.y
		var base_idx: int = i * 4

		vertices.append(Vector3(x, y, 0))
		vertices.append(Vector3(x + tile_w, y, 0))
		vertices.append(Vector3(x + tile_w, y + tile_h, 0))
		vertices.append(Vector3(x, y + tile_h, 0))

		indices.append(base_idx)
		indices.append(base_idx + 1)
		indices.append(base_idx + 2)
		indices.append(base_idx)
		indices.append(base_idx + 2)
		indices.append(base_idx + 3)

	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices

	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

func _process(_delta: float) -> void:
	if player == null or Map.instance == null:
		return

	var mouse_world: Vector2 = get_canvas_transform().affine_inverse() * get_viewport().get_mouse_position()
	var mouse_tile: Vector2i = Vector2i(floori(mouse_world.x / Config.tile_size.x), floori(mouse_world.y / Config.tile_size.y))

	if mouse_tile == _cursor_tile:
		return

	_cursor_tile = mouse_tile

	var path: Array[Vector2] = Map.instance.pathfinding.find_path(player.position, mouse_world)

	if path.size() > 1:
		_rebuild_mesh(path)
		cursor_mesh.visible = true
	else:
		cursor_mesh.visible = false
