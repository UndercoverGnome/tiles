extends Node2D

@export var editorUI: Control
@export var camera: Camera2D

var world: World = load('res://flatlandworld.tres') #eventually add choosable

const cameraspeed: float = 350

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
			world.chunks[x].append(Chunk.new(id, Vector2i(x,y),'unnamed',initialisechunk()))

func _ready() -> void:
	editorUI.updateUI(world.title)

	initialiseworldchunks()


func _process(delta: float) -> void:
	camera.position += Vector2(Input.get_axis('ui_left','ui_right')*cameraspeed*delta,Input.get_axis('ui_up','ui_down')*cameraspeed*delta)
	editorUI.world = world
	editorUI.camera_position = camera.position
	editorUI.queue_redraw()
	DisplayServer.window_set_title('tile engine, editor | fps:'+str(Engine.get_frames_per_second()))
