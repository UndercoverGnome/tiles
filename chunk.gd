extends Resource
class_name Chunk

@export var id: int
@export var coordinates: Vector2i
@export var title: String
@export var tiles: PackedInt32Array

func get_tile(x: int, y: int, chunk_size: int) -> int:
	return tiles[y * chunk_size + x]

func set_tile(x: int, y: int, tile_id: int, chunk_size: int) -> void:
	tiles[y * chunk_size + x] = tile_id
