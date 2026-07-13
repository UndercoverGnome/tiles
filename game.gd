extends Node2D

@export var gameUI: Control
@export var camera: Camera2D
@export var player: CharacterBody2D

var world: World = load('res://flatlandmain.tres') #eventually add choosable

var chunkstoload: Array[Vector2i] = []
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
	if chunk == null or chunk.walltiles.is_empty():
		return

	for x in range(world.chunksize):
		for y in range(world.chunksize):
			var tile = chunk.walltiles[x][y]

			if tile == "empty":
				tilemap.erase_cell(0, Vector2i(x,y))
			else:
				tilemap.set_cell(0,Vector2i(x,y),0,world.tiledict[tile])

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		for coords in loadedtilemaps:
			var tilemap:TileMap = loadedtilemaps[coords]
			var cell:Vector2i = tilemap.local_to_map(tilemap.get_local_mouse_position())

			if !cell.x<0 and !cell.y<0 and !cell.x>=world.chunksize and !cell.y>=world.chunksize:
				var worldchunk = world.chunks[coords.x][coords.y]

				#INTERACT
				var tile = worldchunk.walltiles[cell.x][cell.y]
				match tile:
					"dooropenh1":
						tilemap.set_cell(0, cell, 0, world.tiledict["doorclosedh1"])
						worldchunk.walltiles[cell.x][cell.y] = "doorclosedh1"

					"doorclosedh1":
						tilemap.set_cell(0, cell, 0, world.tiledict["dooropenh1"])
						worldchunk.walltiles[cell.x][cell.y] = "dooropenh1"
					"dooropenh2":
						tilemap.set_cell(0, cell, 0, world.tiledict["doorclosedh2"])
						worldchunk.walltiles[cell.x][cell.y] = "doorclosedh2"

					"doorclosedh2":
						tilemap.set_cell(0, cell, 0, world.tiledict["dooropenh2"])
						worldchunk.walltiles[cell.x][cell.y] = "dooropenh2"
					"dooropenv1":
						tilemap.set_cell(0, cell, 0, world.tiledict["doorclosedv1"])
						worldchunk.walltiles[cell.x][cell.y] = "doorclosedv1"

					"doorclosedv1":
						tilemap.set_cell(0, cell, 0, world.tiledict["dooropenv1"])
						worldchunk.walltiles[cell.x][cell.y] = "dooropenv1"
					"dooropenv2":
						tilemap.set_cell(0, cell, 0, world.tiledict["doorclosedv2"])
						worldchunk.walltiles[cell.x][cell.y] = "doorclosedv2"

					"doorclosedv2":
						tilemap.set_cell(0, cell, 0, world.tiledict["dooropenv2"])
						worldchunk.walltiles[cell.x][cell.y] = "dooropenv2"


func _ready() -> void:
	updatechunks()

func _process(delta: float) -> void:
	if player.velocity.length()>0:
		updatechunks()

	DisplayServer.window_set_title('tile engine, game | fps:'+str(Engine.get_frames_per_second()))
