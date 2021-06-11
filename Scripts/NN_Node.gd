extends Node

class_name NN_Node

var canvas_location := Vector2(0, 0)

var genome_ref
var number := 0
var input_sum := 0.0
var output_value := 0.0
var output_connections := []
var input_connections := []
var layer := 0
const e := 2.71828182846 #Fun fact: Godot doesn't have a literal for the euler constant

#Constructor
func _init(genome, no : int) -> void:
	genome_ref = genome
	number = no

func clone():
	var clone = get_script().new(genome_ref, number)
	clone.layer = layer
	return clone

func Reset():
	input_sum = 0

#The superior sigmoid activation function
func Sigmoid(x : float) -> float:
	var y = 1 / (1 + pow(e, -4.9 * x))
	return y

#The node sens its output to the inputs of the nodes it's connected to
func Engage():
	var output = 0
	if(layer != 0):
		output = Sigmoid(input_sum)
	for x in range(output_connections.size()):
		output_connections[x].to_node.input_sum += output_connections[x].weight * output

func is_connected_to(node):
	if (node.layer == layer):
		return false
	
	if (node.layer < layer):
		for i in node.output_connections:
			if(i.to_node == self):
				return true
	else:
		for i in output_connections:
			if(i.to_node == node):
				return true
	
	return false
