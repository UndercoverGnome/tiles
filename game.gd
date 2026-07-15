extends Node2D

@export var gameUI: Control
@export var camera: Camera2D
@export var player: CharacterBody2D

var world: World = load('res://flatlandmain.tres') #eventually add choosable
var renderer

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_tile = renderer.getTileFromScreenPosition(get_global_mouse_position())

		if mouse_tile.is_empty():
			return

		var chunkcoords: Vector2i = mouse_tile["chunk"]
		var cell: Vector2i = mouse_tile["cell"]
		var tilemap: TileMap = mouse_tile["tilemap"]

		var chunk:Chunk = world.chunks[chunkcoords.x][chunkcoords.y]
		print(chunk.get_tile(cell.x,cell.y,world.chunksize))


func _ready() -> void:
	renderer = load('res://scenes/renderer.tscn').instantiate()
	add_child(renderer)
	renderer.world = world
	renderer.camera = camera
	renderer.updatechunks()

func _process(delta: float) -> void:
	if player.velocity.length()>0:
		renderer.updatechunks()

	DisplayServer.window_set_title('tile engine, game | fps:'+str(Engine.get_frames_per_second()))
