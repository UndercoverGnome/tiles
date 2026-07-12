extends Node2D

@export var editorUI: Control
@export var camera: Camera2D

var world: World = load('res://flatlandmain.tres') #eventually add choosable

const cameraspeed: float = 500

var chunkstoload: Array[Vector2i] = []
var loadedtilemaps: Dictionary = {}

func initialisechunk():
	var tilesarray = []
	for x in range(world.chunksize):
		tilesarray.append([])
		for y in range(world.chunksize):
			if x==0 or x==world.chunksize-1 or y==0 or y==world.chunksize-1:
				tilesarray[x].append('metalwall')
			else:
				tilesarray[x].append('empty')
	return tilesarray

func initialiseworldchunks():
	world.chunks.clear()
	var id=-1
	for x in range(world.size.x):
		world.chunks.append([])
		for y in range(world.size.y):
			id+=1
			var chunk = Chunk.new()

			chunk.id = id
			chunk.coordinates = Vector2i(x, y)
			chunk.title = "unnamed"
			chunk.walltiles = initialisechunk()

			world.chunks[x].append(chunk)


func updatechunks():
	var chunk_size_pixels = world.chunksize * 32

	var camera_chunk := Vector2i(
		floor(camera.position.x / chunk_size_pixels),
		floor(camera.position.y / chunk_size_pixels)
	)

	var chunkloadingshape = [
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
	if chunk == null or chunk.walltiles.is_empty():
		return

	for x in range(world.chunksize):
		for y in range(world.chunksize):
			var tile = chunk.walltiles[x][y]

			if tile == "empty":
				tilemap.erase_cell(0, Vector2i(x,y))
			else:
				tilemap.set_cell(0,Vector2i(x,y),0,world.tiledict[tile])

func _on_save_button_pressed() -> void:
	var result = ResourceSaver.save(world, "res://flatlandmain.tres")#WHY ARE CHUNKS EMPTY ON SERIALISE?
	if result == OK:
		print("World saved ")
	else:
		print("Save failed: ", result)

func _ready() -> void:
	editorUI.updateUI(world, camera.position)
	if world.chunks.is_empty():
		print("ERROR! WORLD.CHUNKS IS EMPTY. INITIALISING CHUNKS")
		initialiseworldchunks()

func _process(delta: float) -> void:
	var movement = Vector2(Input.get_axis('ui_left','ui_right')*cameraspeed*delta,Input.get_axis('ui_up','ui_down')*cameraspeed*delta)
	if movement.length()>0:
		camera.position += movement
		updatechunks()
		editorUI.updateUI(world, camera.position)

	DisplayServer.window_set_title('tile engine, editor | fps:'+str(Engine.get_frames_per_second()))
