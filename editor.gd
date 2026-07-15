extends Node2D

@export var editorUI: Control
@export var camera: Camera2D

var world: World = load('res://flatlandmain.tres') #eventually add choosable
var renderer

const cameraspeed: float = 500

var selectedtile: int = 0

var drawing: bool = false

func initialisechunktiles():
	var tilesarray = []
	for i in range(world.chunksize*world.chunksize):
		tilesarray.append(0)
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

func cameramovement(delta):
	var movement = Vector2(Input.get_axis('ui_left','ui_right')*cameraspeed*delta,Input.get_axis('ui_up','ui_down')*cameraspeed*delta)
	if movement.length()>0:
		camera.global_position += movement
		renderer.updatechunks()
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
		var mouse_tile = renderer.getTileFromScreenPosition(get_global_mouse_position())

		if mouse_tile.is_empty():
			return

		var coords: Vector2i = mouse_tile["chunk"]
		var cell: Vector2i = mouse_tile["cell"]
		var tilemap: TileMap = mouse_tile["tilemap"]

		var worldchunk = world.chunks[coords.x][coords.y]

		worldchunk.set_tile(
			cell.x,
			cell.y,
			selectedtile,
			world.chunksize
		)

		renderer.update_tile(
			coords,
			cell,
			selectedtile
		)

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
	if world.chunks.is_empty():
		print("ERROR! WORLD.CHUNKS IS EMPTY. INITIALISE CHUNKS!!")
		initialiseworldchunks()
	renderer = load('res://scenes/renderer.tscn').instantiate()
	add_child(renderer)
	renderer.world = world
	renderer.camera = camera
	renderer.updatechunks()

func _process(delta: float) -> void:
	handleselectedtileinput()
	handledrawing()
	cameramovement(delta)

	DisplayServer.window_set_title('tile engine, editor | fps:'+str(Engine.get_frames_per_second()))
