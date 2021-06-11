extends Node2D
# Node to load the NN based on new game or load from save
var pop_display = null

func _init():
	pop_display = preload("res://Scenes/NN_Population_Display.tscn").instance()
	pop_display.agents_to_load = 4
	add_child(pop_display)
	General_Manager.finished_loading_NN(pop_display.ref_population)
