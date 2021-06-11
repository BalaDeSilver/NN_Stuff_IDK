extends Node

class_name NN_Agent

var id := 0
const decision_threshold := 0.8

var agent_name := ""
var pop_ref
var fitness := 0.0
var brain
var vision := []
var decision := []
var unadjusted_fitness := 0.0
var lifespan := 0.0
var best_score := 0.0
var gen := 0
var score := 0.0
var active := true

var relative_position := Vector2(0, 0)

var genome_inputs := 0
var genome_outputs := 0

#Constructor
func _init(inputs : int, outputs : int, clone : bool, pop, uid : int):
	genome_inputs = inputs
	genome_outputs = outputs
	pop_ref = pop
	id = uid
	if (!clone):
		brain = NN_Genome.new(genome_inputs, genome_outputs, false, self)
		self.add_child(brain)
	decision.resize(genome_outputs)
	for i in decision:
		i = 0.0
	vision.resize(genome_inputs)

func clone():
	var clone = get_script().new(genome_inputs, genome_outputs, true)
	clone.brain = brain.clone()
	clone.add_child(clone.brain)
	clone.fitness = fitness
	clone.brain.generate_network()
	return clone

func look():
	pass

func move():
	pass

func calculate_fitness():
	fitness = score
	return fitness

func think():
	if (active):
		look()
		decision = brain.feed_forward(vision)
	else:
		for i in decision:
			i = 0.0

func update():
	pass

#sex 2: electric boogaloo
func crossover(player2):
	var child = get_script().new(genome_inputs, genome_outputs, true)
	child.brain = brain.crossover(player2.brain)
	child.add_child(child.brain)
	child.brain.generate_network()
	return child
	
