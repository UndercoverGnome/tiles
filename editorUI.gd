extends Control

var worldtitlelabel: Node

#chunkvisualiser
var world: World
var camera_position: Vector2
var visualiser_tile_size := 16

func updateUI(world: World, cameraposition):
	self.world=world
	worldtitlelabel=find_child('worldtitlelabel')
	worldtitlelabel.text=world.title
	camera_position=cameraposition
	queue_redraw()

func visualisechunks(camposition, world, visualisertilesize):
	#DRAW CHUNKS IN GREEN IF THEY HAVE TILE DATA
	for x in range(world.chunks.size()):
		for y in range(world.chunks[x].size()):
			print(world.chunks[x][y])
			if world.chunks[x][y].walltiles != []:
				draw_rect(Rect2(Vector2(world.chunks[x][y].coordinates.x*visualisertilesize,world.chunks[x][y].coordinates.y*visualisertilesize),Vector2(visualisertilesize-1,visualisertilesize-1)),Color.GREEN)
	#DRAW CAMERA VISUALISER
	draw_circle(Vector2(camposition.x/(world.chunksize*2),camposition.y/(world.chunksize*2)),2,Color.BLUE)

func _draw():
	if world:
		visualisechunks(camera_position, world, visualiser_tile_size)
