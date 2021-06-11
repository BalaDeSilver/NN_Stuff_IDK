extends Node

class_name NN_Connection

var genome_ref
var from_node
var to_node
var weight : float = 0.0
var number : int = 0
var enabled : bool = true
var innovation : int = 0

#Constructor
func _init(inno : int, genome, from, to, w : float, n : int):
	genome_ref = genome
	from_node = from
	to_node = to
	weight = w
	number = n
	innovation = inno

func mutate_weight():
	var rand2 = General_Manager.rng.randf()
	if(rand2 < 0.1):
		weight = General_Manager.rng.randf_range(-1, 1)
	else:
		weight += General_Manager.rng.randfn() / 50
		weight = clamp(weight, -1, 1)

func clone(from : NN_Node, to : NN_Node):
	var clone = get_script().new(innovation, genome_ref, from, to, weight, General_Manager.networks[number].genes.size())
	clone.enabled = enabled
	return clone
