extends Node2D

var world: World
var camera: Camera2D

var loadedtilemaps: Dictionary = {}

const chunkloadingshape = [
		Vector2i(0,0),
		Vector2i(0,1),
		Vector2i(0,-1),
		Vector2i(1,0),
		Vector2i(1,1),
		Vector2i(1,-1),
		Vector2i(-1,0),
		Vector2i(-1,1),
		Vector2i(-1,-1),
	]

func get_tilemap(chunk_coords: Vector2i) -> TileMap:
	return loadedtilemaps.get(chunk_coords)

func get_loaded_chunks() -> Array[Vector2i]:
	return loadedtilemaps.keys()

func updatechunks():
	var chunk_size_pixels = world.chunksize * 32

	var camera_chunk := Vector2i(
		floor(camera.global_position.x / chunk_size_pixels),
		floor(camera.global_position.y / chunk_size_pixels)
	)

	var wanted_chunks: Array[Vector2i] = []

	# Determine which chunks should be loaded
	for offset in chunkloadingshape:
		var current_chunk = camera_chunk + offset

		if (
			current_chunk.x >= 0
			and current_chunk.x < world.size.x
			and current_chunk.y >= 0
			and current_chunk.y < world.size.y
		):
			wanted_chunks.append(current_chunk)

	# Load missing chunks
	for current_chunk in wanted_chunks:
		if !loadedtilemaps.has(current_chunk):
			var tilemap := TileMap.new()
			tilemap.tile_set = world.tileset
			tilemap.position = current_chunk * chunk_size_pixels

			add_child(tilemap)

			drawchunk(
				tilemap,
				world.chunks[current_chunk.x][current_chunk.y]
			)

			loadedtilemaps[current_chunk] = tilemap

	# Remove chunks that are no longer needed
	var remove_queue: Array[Vector2i] = []

	for chunk in loadedtilemaps:
		if !wanted_chunks.has(chunk):
			remove_queue.append(chunk)

	for chunk in remove_queue:
		loadedtilemaps[chunk].queue_free()
		loadedtilemaps.erase(chunk)

func drawchunk(tilemap: TileMap, chunk: Chunk):
	if chunk == null or chunk.tiles.is_empty():
		return

	for x in range(world.chunksize):
		for y in range(world.chunksize):
			var tile = chunk.get_tile(x,y,world.chunksize)
			tilemap.set_cell(0,Vector2i(x,y),0,world.tiledict[tile])

func getTileFromScreenPosition(screenposition: Vector2) -> Dictionary:
	for coords in loadedtilemaps:
		var tilemap: TileMap = loadedtilemaps[coords]

		var local_position = tilemap.to_local(screenposition)
		var cell: Vector2i = tilemap.local_to_map(local_position)

		if cell.x >= 0 \
		and cell.y >= 0 \
		and cell.x < world.chunksize \
		and cell.y < world.chunksize:
			return {
				"chunk": coords,
				"cell": cell,
				"tilemap": tilemap
			}

	return {}

func update_tile(chunk: Vector2i, cell: Vector2i, tile_id: int):
	var tilemap = loadedtilemaps.get(chunk)

	if tilemap:
		tilemap.set_cell(
			0,
			cell,
			0,
			world.tiledict[tile_id]
		)
