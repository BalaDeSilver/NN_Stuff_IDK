extends Node

class_name NN_Genome

var agent_ref
var genes : Array = [] #Connections
var nodes : Array = [] #Nodes
var inputs : int = 0 #How many input nodes
var outputs : int = 0 #How many output nodes
var layers : int = 2 #How many layers in the network
var next_node : int = 0 #Meta variable
var bias_node : int = 0 #Bias node
var network : Array = [] #A list of the nodes in the order that they need to be considered in the NN

var top_left = Vector2(INF, INF)
var bottom_right = Vector2(-INF, -INF)

#Constructor
func _init(inp : int, out : int, clone : bool, agent) -> void:
	inputs = inp
	outputs = out
	agent_ref = agent
	
	if(!clone):
		var local_next_connection_number = 0
		
		#Creates input nodes
		for i in range(inputs):
			nodes.append(NN_Node.new(self, i))
			next_node += 1
			nodes[i].layer = 0
			add_child(nodes[i])
		
		#Creates output nodes
		for i in range(outputs):
			nodes.append(NN_Node.new(self, inputs + i))
			next_node += 1
			nodes[inputs + i].layer = 1
			add_child(nodes[inputs + i])
		
		#Creates bias node
		nodes.append(NN_Node.new(self, next_node))
		add_child(nodes[next_node])
		bias_node = next_node
		next_node += 1
		nodes[bias_node].layer = 0
		
		#Connect inputs to outputs
		for i in range(inputs):
			for j in range(outputs):
				genes.append(NN_Connection.new(local_next_connection_number, self, nodes[i], nodes[inputs + j], General_Manager.rng.randf_range(-1, 1), local_next_connection_number))
				local_next_connection_number += 1
		#Connect bias
		for j in range(outputs):
			genes.append(NN_Connection.new(local_next_connection_number, self, nodes[bias_node], nodes[inputs + j], General_Manager.rng.randf_range(-1, 1), local_next_connection_number))
			local_next_connection_number += 1
		
		for i in genes:
			add_child(i)
			pass
		
		if(agent_ref.pop_ref.next_connection_number.size() < agent_ref.id + 1):
			agent_ref.pop_ref.next_connection_number.append(local_next_connection_number)
		else:
			agent_ref.pop_ref.next_connection_number[agent_ref.id] = local_next_connection_number

#Returns the node with a matching number
#Sometimes, nodes will not be in order
func get_NN_node(num : int) -> NN_Node:
	for i in nodes:
		if(i.number == num):
			return i
	return null

#Adds the connections' references between the nodes, so they can access each other during feed forward
func connect_nodes() -> void:
	for i in nodes:
		i.output_connections.clear()
	
	for i in genes:
		i.from_node.output_connections.append(i)
		i.to_node.input_connections.append(i)

#Processes the node output based on input
func feed_forward(input_values : Array) -> Array:
	for i in range(inputs):
		nodes[i].output_value = input_values[i]
	nodes[bias_node].output_value = 1.0 #Bias output is always 1
	
	for i in network:
		i.Engage()
	
	for i in nodes:
		i.Reset()
	
	var outs = []
	outs.resize(outputs)
	for i in outs:
		i = nodes[inputs + i].output_value
	return outs
	
#Sets up the NN as a list of nodes in the right order to be engaged
func generate_network() -> void:
	connect_nodes()
	network = []
	#For each layer, add the node in that layer, since layers cannot connect to themselves, there is no need to order the nodes within a layer.
	for i in range(layers): #For each layer
		for j in nodes: #For each node
			if(j.layer == i): #If that node is in that layer
				network.append(j)

func fully_connected():
	var max_connections = 0
	var nodes_in_layers = []
	
	for _i in range(layers):
		nodes_in_layers.append(0)
	
	for i in nodes:
		nodes_in_layers[i.layer] += 1
	
	for i in range(layers - 1):
		var nodes_in_front = 0
		for j in range(i + 1, layers):
			nodes_in_front += nodes_in_layers[j]
		
		max_connections += nodes_in_layers[i] * nodes_in_front
	
	if (max_connections == genes.size()):
		return true
	return false

func random_connection_nodes_are_shit(rand1 : int, rand2 : int):
	if(nodes[rand1].layer == nodes[rand2].layer or nodes[rand1].is_connected_to(nodes[rand2])):
		return true
	return false

func get_innovation_number(innovation_history : Array, from : NN_Node, to : NN_Node):
	var isnew = true
	var connection_innovation_number = agent_ref.pop_ref.next_connection_number[agent_ref.id]
	for i in innovation_history:
		if(i.matches(self, from, to)):
			isnew = false
			connection_innovation_number = i.innovation
			break
	
	if(isnew):
		var inno_numbers = []
		for i in genes:
			inno_numbers.append(i.innovation)
		
		innovation_history.append(NN_Connection_History.new(from.number, to.number, connection_innovation_number, inno_numbers))
		agent_ref.pop_ref.next_connection_number[agent_ref.id] += 1
	
	return connection_innovation_number

func add_random_connection(innovation_history : Array):
	if (fully_connected()):
		return
	
	var random_node_01 = General_Manager.rng.randi_range(0, nodes.size() - 1)
	var random_node_02 = General_Manager.rng.randi_range(0, nodes.size() - 1)
	while (random_connection_nodes_are_shit(random_node_01, random_node_02)):
		random_node_01 = General_Manager.rng.randi_range(0, nodes.size() - 1)
		random_node_02 = General_Manager.rng.randi_range(0, nodes.size() - 1)
	
	if (nodes[random_node_01].layer > nodes[random_node_02]):
		var temp = random_node_02
		random_node_02 = random_node_01
		random_node_01 = temp
	
	var connection_innovation_number = get_innovation_number(innovation_history, nodes[random_node_01], nodes[random_node_02])
	
	genes.append(NN_Connection.new(connection_innovation_number, self, nodes[random_node_01], nodes[random_node_02], General_Manager.rng.randf(-1, 1), genes.size()))
	self.add_child(genes.back())
	connect_nodes()

func add_random_node(innovation_history : Array):
	if (genes.size() == 0):
		add_random_connection(innovation_history)
		return
	
	var random_connection = General_Manager.rng.randi_range(0, genes.size() - 1)
	while (genes[random_connection].from_node == nodes[bias_node]):
		random_connection = General_Manager.rng.randi_range(0, genes.size() - 1)
	
	genes[random_connection].enabled = false
	
	var new_node_no = next_node
	nodes.append(NN_Node.new(self, new_node_no))
	self.add_child(nodes[new_node_no])
	next_node += 1
	
	var connection_innovation_number = get_innovation_number(innovation_history, genes[random_connection].from_node, get_NN_node(new_node_no))
	genes.append(NN_Connection.new(connection_innovation_number, self, genes[random_connection].from_node, get_NN_node(new_node_no), 1, genes.size()))
	self.add_child(genes.back())
	get_NN_node(new_node_no).layer = genes.back().from_node.layer + 1
	
	connection_innovation_number = get_innovation_number(innovation_history, get_NN_node(new_node_no), genes[random_connection].to_node)
	genes.append(NN_Connection.new(connection_innovation_number, self, get_NN_node(new_node_no), genes[random_connection].to_node, genes[random_connection].weight, genes.size()))
	self.add_child(genes.back())
	
	connection_innovation_number = get_innovation_number(innovation_history, get_NN_node(bias_node), get_NN_node(new_node_no))
	genes.append(NN_Connection.new(connection_innovation_number, self, get_NN_node(bias_node), get_NN_node(new_node_no), 0, genes.size()))
	self.add_child(genes.back())
	
	
	if(get_NN_node(new_node_no).layer == genes[random_connection].to_node.layer or get_NN_node(new_node_no).layer == genes[random_connection].from_node.layer):
		for i in range(nodes.size() - 1):
			if (nodes[i].layer >= get_NN_node(new_node_no).layer):
				nodes[i].layer += 1
		layers += 1
	
	connect_nodes()
	return get_NN_node(new_node_no)

func mutate(innovation_history : Array):
	if (genes.size() == 0):
		add_random_connection(innovation_history)
	
	var rand = General_Manager.rng.randf()
	if (rand < 0.8):
		for i in genes:
			i.mutate_weight()
	
	rand = General_Manager.rng.randf()
	if (rand < 0.08):
		add_random_connection(innovation_history)
	
	rand = General_Manager.rng.randf()
	if (rand < 0.02):
		add_random_node(innovation_history)

func matching_gene(parent2, innovation_number : int):
	var x = 0
	while x < parent2.genes.size():
		if (parent2.genes[x].innovation_number == innovation_number):
			return x
		x += 1
	return -1

func clone():
	var clone = get_script().new(inputs, outputs, true)
	
	for i in nodes:
		clone.nodes.append(i.clone())
		clone.add_child(clone.nodes.back())
	
	for i in genes:
		clone.genes.append(i.clone(clone.get_NN_node(i.from_node.number), clone.get_NN_node(i.to_node.number)))
		clone.add_child(clone.genes.back())
	
	clone.layers = layers
	clone.next_node = next_node
	clone.bias_node = bias_node
	clone.connect_nodes()
	
	return clone

func crossover(parent2):
	var child = get_script().new(inputs, outputs, true, agent_ref)
	child.genes.clear()
	child.nodes.clear()
	
	var child_genes = []
	var is_enabled = []
	
	for i in range(genes.size()):
		var set_enabled = true
		
		var parent2_gene = matching_gene(parent2, genes[i].innovation)
		if (parent2_gene > -1):
			if (!genes[i].enabled or !parent2.genes[parent2_gene].enabled):
				if (General_Manager.rng.randf() < 0.75):
					set_enabled = false
			
			var rand = General_Manager.rng.randf()
			if (rand < 0.5):
				child_genes.append(genes[i])
			else:
				child_genes.append(parent2.genes[i])
		else:
			child_genes.append(genes[i])
			set_enabled = genes[i].enabled
		
		is_enabled.append(set_enabled)
	
	for i in nodes:
		child.nodes.append(i.clone())
		child.add_child(child.nodes.back())
	
	for i in range(child_genes.size()):
		child.genes.append(child_genes[i].clone())
		child.genes[i].enabled = is_enabled[i]
		child.add_child(child.genes.back())
	
	child.connect_nodes()
	return child
