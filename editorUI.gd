extends Control

var worldtitlelabel: Node

func updateUI(worldtitle: String):
	worldtitlelabel=find_child('worldtitlelabel')

	worldtitlelabel.text=worldtitle
