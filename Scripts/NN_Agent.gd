extends Node

# The class for each agent in the network.
# Each agent only has one brain.

class_name NN_Agent

const decision_threshold := 0.8 # If the output node value is bigger than this, return true, else, return false

var id := 0
var agent_name := ""
var pop_ref
var fitness := 0.0
var brain # The reference downwards into the respective Neural Network
var vision := [] # Another way to reference the first layer input
var decision := [] # Another way to reference the last layer output
var active := true

# These values are used to sort the populations amongst each other. They go mostly unused in this project (for now, at least)
var unadjusted_fitness := 0.0
var lifespan := 0.0
var best_score := 0.0
var gen := 0
var score := 0.0

var genome_inputs := 0
var genome_outputs := 0

# This references the location it should render in the canvas, relative to its parent.
var relative_position := Vector2(0, 0)

# Constructor
func _init(inputs : int, outputs : int, clone : bool, pop, uid : int):
	genome_inputs = inputs
	genome_outputs = outputs
	pop_ref = pop
	id = uid
	if (!clone):
		brain = NN_Genome.new(genome_inputs, genome_outputs, false, self, pop_ref.innovation_history)
		self.add_child(brain)
	decision.resize(genome_outputs)
	for i in decision:
		i = 0.0
	vision.resize(genome_inputs)

# As the duplicate() function sucks in Godot, this is really necessary.
func clone():
	var clone = get_script().new(genome_inputs, genome_outputs, true)
	clone.brain = brain.clone()
	clone.add_child(clone.brain)
	clone.fitness = fitness
	clone.brain.generate_network()
	return clone

# All empty functions are virtually virtual.
func update():
	pass
# These should mostly be used as you exted this script via another script.
func look():
	pass
#Todo:A better fitted scipt class to inherit
func move():
	pass

# What does a Neural Network do?
# Think, anon, think!
func think():
	if (active):
		look()
		decision = brain.feed_forward(vision)
	else:
		for i in decision:
			i = 0.0

# This is a virtual function. Write another one to fit you better. Or not, who cares.
func calculate_fitness():
	fitness = score
	return fitness

# Sex 2: Electric Boogaloo
func crossover(player2):
	var child = get_script().new(genome_inputs, genome_outputs, true, pop_ref, pop_ref.pop.size())
	child.brain = brain.crossover(player2.brain)
	child.add_child(child.brain)
	child.brain.agent_ref = child
	#child.brain.generate_network()
	return child
	
