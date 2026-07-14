extends Node2D

@export var editorUI: Control
@export var camera: Camera2D

var world: World = load('res://flatlandmain.tres') #eventually add choosable

const cameraspeed: float = 500

var loadedtilemaps: Dictionary = {}
var selectedtile: int = 0

var drawing: bool = false

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

func gettilefromxy(chunk: Chunk, x: int, y: int) -> int:
	return chunk.tiles[(y*world.chunksize)+x]

func initialisechunktiles():
	var tilesarray = []
	for i in range(world.chunksize*world.chunksize):
		tilesarray.append(randi_range(0,1))
	return tilesarray

func initialiseworldchunks():
	world.chunks.clear()
	var id=0
	for x in range(world.size.x):
		world.chunks.append([])
		for y in range(world.size.y):
			var chunk = Chunk.new()

			chunk.id = id
			chunk.coordinates = Vector2i(x, y)
			chunk.title = "unnamed"
			chunk.tiles = initialisechunktiles()

			world.chunks[x].append(chunk)
			id+=1

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
			var tile = gettilefromxy(chunk, x, y)
			tilemap.set_cell(0,Vector2i(x,y),0,world.tiledict[tile])

func cameramovement(delta):
	var movement = Vector2(Input.get_axis('ui_left','ui_right')*cameraspeed*delta,Input.get_axis('ui_up','ui_down')*cameraspeed*delta)
	if movement.length()>0:
		camera.global_position += movement
		updatechunks()
		editorUI.updateUI(world, camera.global_position)

func handleselectedtileinput():
	if Input.is_action_just_pressed('0'): #IDEALLY GET RID OF THIS LATER
		print('empty')
		selectedtile=0
	if Input.is_action_just_pressed('1'):
		print('metalwall')
		selectedtile=1

func handledrawing():
	if drawing:
		for coords in loadedtilemaps:
			var tilemap:TileMap = loadedtilemaps[coords]
			var cell:Vector2i = tilemap.local_to_map(tilemap.get_local_mouse_position())

			if !cell.x<0 and !cell.y<0 and !cell.x>=world.chunksize and !cell.y>=world.chunksize:

				var worldchunk = world.chunks[coords.x][coords.y]

				tilemap.set_cell(0,cell,0,world.tiledict[selectedtile])
				worldchunk.tiles[(cell.y*world.chunksize)+cell.x]=selectedtile

func _on_save_button_pressed() -> void:
	var result = ResourceSaver.save(world, "res://flatlandmain.tres")
	if result == OK:
		print("World saved ")
	else:
		print("Save failed: ", result)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		drawing = event.pressed

func _ready() -> void:
	editorUI.updateUI(world, camera.global_position)
	print(world.chunks)
	print(world.size)
	if world.chunks.is_empty():
		print("ERROR! WORLD.CHUNKS IS EMPTY. INITIALISE CHUNKS!!")
		initialiseworldchunks()
	updatechunks()
	print(world.chunks)

func _process(delta: float) -> void:
	handleselectedtileinput()
	handledrawing()
	cameramovement(delta)

	DisplayServer.window_set_title('tile engine, editor | fps:'+str(Engine.get_frames_per_second()))
