extends Node2D

@export var editorUI: Control


var world: World = load('res://flatlandworld.tres') #eventually add choosable

var tilemap

var camerapos: Vector2

const cameraspeed: float = 350

func drawchunk(chunk: Chunk):
	for x in range(world.chunksize):
		for y in range(world.chunksize):
			tilemap.set_cell(0,Vector2i(x,y),0,world.tiledict[chunk.walltiles[x][y]])
	tilemap.z_index=-1

func initialisesinglechunk():
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
			world.chunks[x].append(Chunk.new(id, Vector2i(x,y),'unnamed',initialisesinglechunk()))

func visualisechunks(size):
	#for x in range(world.size.x):
	#	for y in range(world.size.y):
	#		draw_rect(Rect2(Vector2(x*size,y*size),Vector2(size-1,size-1)),Color.RED)
	#DRAW REAL CHUNKS IN GREEN OVER TOP, WITH REAL POSITIONS DERIVED FROM CHUNKDATA
	#for x in range(world.chunks.size()):
	#	for y in range(world.chunks[x].size()):
	#		draw_rect(Rect2(Vector2(world.chunks[x][y].coordinates.x*size,world.chunks[x][y].coordinates.y*size),Vector2(size-1,size-1)),Color.YELLOW)

	#DRAW CHUNKS IN GREEN IF THEY HAVE TILE DATA
	for x in range(world.chunks.size()):
		for y in range(world.chunks[x].size()):
			if world.chunks[x][y].walltiles != []:
				draw_rect(Rect2(Vector2(world.chunks[x][y].coordinates.x*size,world.chunks[x][y].coordinates.y*size),Vector2(size-1,size-1)),Color.GREEN)
	#DRAW CAMERA VISUALISER
	draw_circle(Vector2(camerapos.x/(world.chunksize*2),camerapos.y/(world.chunksize*2)),2,Color.BLUE)

func _ready() -> void:
	editorUI.updateUI(world.title)

	camerapos=Vector2(0,0)#Vector2(get_viewport().size.x/2-(32*world.chunksize/2),(get_viewport().size.y/2)-(32*world.chunksize/2))

	initialiseworldchunks()

	tilemap = TileMap.new()
	add_child(tilemap)
	tilemap.tile_set = load(world.tileset.resource_path)
	drawchunk(world.chunks[0][0])

func _draw() -> void:
	visualisechunks(16)

func _process(delta: float) -> void:
	camerapos+=Vector2(Input.get_axis('ui_left','ui_right')*cameraspeed*delta,Input.get_axis('ui_up','ui_down')*cameraspeed*delta)
	tilemap.position=-camerapos
	queue_redraw()
	DisplayServer.window_set_title('tile engine, editor | fps:'+str(Engine.get_frames_per_second()))
