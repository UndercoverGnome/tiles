class_name Chunk

var id: int
var coordinates: Vector2i
var title: String
var walltiles: Array

func _init(id:int, coordinates:Vector2i, title:String, walltiles:Array) -> void:
	self.id=id
	self.coordinates=coordinates
	self.title=title
	self.walltiles=walltiles
