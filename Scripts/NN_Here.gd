extends Node2D
# Node to load the NN based on new game or load from save
#Todo:Load and save game
var pop_display = null

func _init():
	# On startup, Link the signal to start the NN.
	General_Manager.connect("new_NN", self, "start_NN")
	# _init triggers immediatelly before the add_child() function is called, in the child.
	# _ready triggers immediatelly after the add_child() function is executed.

func start_NN():
	# This allows for an encapsulation of the NN inside this scene, I think
	pop_display = preload("res://Scenes/NN_Population_Display.tscn").instance()
	# I'm setting this here, even though it isn't optimal.
	add_child(pop_display)
