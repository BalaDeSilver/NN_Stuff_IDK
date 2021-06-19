extends Node2D
# Node to load the NN based on new game or load from save
#Todo:Load and save game
var pop_display = null

func _init():
	# On startup, create an instance of the Population Display scene.
	# This allows for an encapsulation of the NN inside this scene, I think
	pop_display = preload("res://Scenes/NN_Population_Display.tscn").instance()
	# I'm setting this here, even though it isn't optimal.
	#Todo:Optimally load agents
	pop_display.agents_to_load = 4
	# _init triggers immediatelly before the add_child() function is called, in the child.
	# _ready triggers immediatelly after the add_child() function is executed.
	add_child(pop_display)
