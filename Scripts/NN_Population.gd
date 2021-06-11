extends Node

class_name NN_Population

var pop : Array = []

var best_agent
var best_score : float = 0
var gen : int = 0
var innovation_history : Array = []
var gen_agents : Array = []
var species : Array = []
var kill_stale : bool = false

var next_connection_number : Array = []

var MASS_EXTINCTION : bool = false

#Constructor
func _init(size : int):
	for i in range(size):
		pop.append(NN_Agent.new(4, 4, false, self, i))
		pop[i].brain.generate_network()
		pop[i].brain.mutate(innovation_history)
		add_child(pop[i])

func update_alive():
	for i in pop:
		i.think()
		i.update()

func set_best_agent():
	var temp_best = species[0].agents[0]
	temp_best.gen = gen
	if(temp_best.fitness > best_score):
		gen_agents.append(temp_best.clone())
		best_score = temp_best.fitness
		best_agent = gen_agents.back()

func speciate():
	for i in species:
		i.actors.clear()
	
	for i in pop:
		var species_found = false
		for j in species:
			if (j.same_species(i.brain)):
				j.add_to_species(i)
				species_found = true
				break
		if (!species_found):
			species.append(NN_Species.new(i))

func calculate_fitness():
	for i in pop:
		i.calculate_fitness()

func sort_species():
	for i in species:
		i.sort_species()
	
	var temp = []
	for i in species:
		var maximum = -INF
		var max_index = 0
		for j in range(species.size()):
			if (species[j].best_fitness > maximum):
				maximum = species[j].best_fitness
				max_index = j
		
		temp.append(species[max_index])
		species.remove(max_index)
	
	species = temp

func kill_stale_species():
	var i = 0
	while (i < species.size()):
		if (species[i].staleness >= 15):
			species.remove(i)
			i -= 1
		i += 1

func get_avg_fitness_sum():
	var average_sum = 0
	for i in species:
		average_sum += i.average_sum
	return average_sum

func kill_bad_species():
	var i = 0
	var average_sum = get_avg_fitness_sum()
	while i < species.size():
		if (species[i].average_fitness / average_sum * pop.size() < 1):
			species.remove(i)
			i -= 1
		i += 1

func cull_species():
	for i in species:
		i.cull()
		i.fitness_sharing()
		i.set_average()

func mass_extinction():
	for _i in range(5, species.size()):
		species.remove(5)

func natural_selection():
	speciate()
	calculate_fitness()
	sort_species()
	if(MASS_EXTINCTION):
		mass_extinction()
		MASS_EXTINCTION = false
	cull_species()
	set_best_agent()
	if (kill_stale):
		kill_stale_species()
	kill_bad_species()
	
	var average_sum = get_avg_fitness_sum()
	var children = []
	
	for i in species:
		children.append(i.champ.clone())
		var no_of_children = floor(i.average_fitness / average_sum * pop.size()) - 1
		for _j in range(no_of_children):
			children.append(i.give_bebe(innovation_history))
	
	while(children.size() < pop.size()):
		children.append(species[0].give_bebe(innovation_history))
	
	for i in pop:
		i.get_parent().remove_child(i)
	
	pop = children
	gen += 1
	
	for i in pop:
		self.add_child(i)
		i.brain.generate_network()
