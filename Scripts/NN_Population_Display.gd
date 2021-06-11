extends Node2D

var ref_population : NN_Population = null
var canvas_location := Vector2(0, 0)
var agents_to_load := 1
var agents := []

func _ready():
	ref_population = NN_Population.new(agents_to_load)
	agents.resize(ref_population.pop.size())
	add_child(ref_population)
	for i in range(agents.size()):
		agents[i] = preload("res://Scenes/NN_Agent_Display.tscn").instance()
		agents[i].ref_agent = ref_population.pop[i]
		add_child(agents[i])
