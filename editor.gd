extends Node2D

@export var editorUI: Control
@export var camera: Camera2D

var world: World = load('res://flatlandworld.tres') #eventually add choosable

const cameraspeed: float = 350

var chunkstoload: Array[Vector2i] = []
var loadedtilemaps: Dictionary = {}

func save_world():
	ResourceSaver.save(world, "res://flatlandworld.tres")

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
	var id=-1
	for x in range(world.size.x):
		world.chunks.append([])
		for y in range(world.size.y):
			id+=1
			world.chunks[x].append(Chunk.new(id, Vector2i(x,y),'unnamed',initialisechunk()))#WHY ARE CHUNKS EMPTY?????


func updatechunks():
	var chunk_size_pixels = world.chunksize * 32

	var current_chunk := Vector2i(
		floor(camera.position.x / chunk_size_pixels),
		floor(camera.position.y / chunk_size_pixels)
	)

	if (current_chunk.x >= 0 and current_chunk.x < world.size.x and current_chunk.y >= 0 and current_chunk.y < world.size.y):
		if !loadedtilemaps.has(current_chunk):
			var tilemap := TileMap.new()
			tilemap.tile_set = world.tileset
			tilemap.position = current_chunk * chunk_size_pixels

			add_child(tilemap)

			if (current_chunk.x < world.chunks.size() and current_chunk.y < world.chunks[current_chunk.x].size()):
				drawchunk(tilemap, world.chunks[current_chunk.x][current_chunk.y])

			loadedtilemaps[current_chunk] = tilemap

	var remove_queue := []

	for chunk in loadedtilemaps:
		if chunk != current_chunk:
			remove_queue.append(chunk)

	for chunk in remove_queue:
		loadedtilemaps[chunk].queue_free()
		loadedtilemaps.erase(chunk)

func drawchunk(tilemap: TileMap, chunk: Chunk):
	for x in range(world.chunksize):
		for y in range(world.chunksize):
			var tile = chunk.walltiles[x][y]

			if tile == "empty":
				tilemap.erase_cell(0, Vector2i(x,y))
			else:
				tilemap.set_cell(0,Vector2i(x,y),0,world.tiledict[tile])

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

	if Input.is_action_just_pressed('ui_accept'):
		print('saved!')
		save_world()

	DisplayServer.window_set_title('tile engine, editor | fps:'+str(Engine.get_frames_per_second()))
