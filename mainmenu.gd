extends Node2D

@export var modeoption: OptionButton


func _process(delta: float) -> void:
	DisplayServer.window_set_title('tile engine, main menu | fps:'+str(Engine.get_frames_per_second()))

func _on_worldselectbutton_pressed() -> void: #DO I WANT TO PICK IN MENU, OR PICK IN EDITOR AND GAME
	pass #FILESELECT


func _on_startbutton_pressed() -> void:
	if modeoption.selected==0:
		print('editor!')
		get_tree().change_scene_to_file('res://scenes/editor.tscn')
	else:
		print('game!')
