extends Node2D

var ref_genome : NN_Genome = null
var nodes_display_list := []
var connection_display_list := []
var nodes_by_layer := []

var current_layer_sorting := 0

func _ready():
	nodes_display_list.resize(ref_genome.nodes.size())
	connection_display_list.resize(ref_genome.genes.size())
	
	nodes_by_layer.resize(ref_genome.layers)
	for i in range(nodes_by_layer.size()):
		nodes_by_layer[i] = []
	
	for i in range(nodes_display_list.size()):
		nodes_display_list[i] = preload("res://Scenes/NN_Node_Display.tscn").instance()
		nodes_display_list[i].z_index = 1
		nodes_display_list[i].ref_node = ref_genome.nodes[i]
		
		nodes_by_layer[nodes_display_list[i].ref_node.layer].append(nodes_display_list[i])
		add_child(nodes_display_list[i])
	
	for i in range(nodes_by_layer.size()):
		for j in range(nodes_by_layer[i].size()):
			nodes_by_layer[i][j].position = Vector2((i * 128 + i * General_Manager.node_spacing.x), (j * 128 + j * General_Manager.node_spacing.y))
			nodes_by_layer[i][j].ref_node.canvas_location = nodes_by_layer[i][j].position
	
	for i in range(connection_display_list.size()):
		connection_display_list[i] = preload("res://Scenes/NN_Connection_Display.tscn").instance()
		connection_display_list[i].ref_connection = ref_genome.genes[i]
		add_child(connection_display_list[i])
	
	ref_genome.generate_network()
	
	General_Manager.connect("rerender", self, "redefine_margin")
	General_Manager.connect("redraw", self, "redraw")
	call_deferred("redefine_margin", ref_genome.agent_ref.id)

func sort_layer(a, b):
	var avg_a = 0.0
	var avg_b = 0.0
	for i in range(nodes_by_layer[current_layer_sorting - 1].size()):
		if(nodes_by_layer[current_layer_sorting - 1][i].ref_node.number != ref_genome.bias_node):
			if(nodes_by_layer[current_layer_sorting - 1][i].ref_node.is_connected_to(a.ref_node)):
				avg_a += i
			if(nodes_by_layer[current_layer_sorting - 1][i].ref_node.is_connected_to(b.ref_node)):
				avg_b += i
	avg_a /= a.ref_node.input_connections.size() - 1
	avg_b /= b.ref_node.input_connections.size() - 1
	print(str(a.ref_node.number) + " | " + str(a.ref_node.input_connections.size()) + " | " + str(b.ref_node.number) + " | " + str(b.ref_node.input_connections.size()) + " | " + str(avg_a < avg_b))
	return (avg_a <= avg_b)

func redraw():
	for i in nodes_display_list:
		i.free()
	for i in connection_display_list:
		i.free()

	nodes_display_list.resize(ref_genome.nodes.size())
	connection_display_list.resize(ref_genome.genes.size())
	
	nodes_by_layer.resize(ref_genome.layers)
	for i in range(nodes_by_layer.size()):
		nodes_by_layer[i] = []
	
	for i in range(nodes_display_list.size()):
		nodes_display_list[i] = preload("res://Scenes/NN_Node_Display.tscn").instance()
		nodes_display_list[i].z_index = 1
		nodes_display_list[i].ref_node = ref_genome.nodes[i]
		
		nodes_by_layer[nodes_display_list[i].ref_node.layer].append(nodes_display_list[i])
		add_child(nodes_display_list[i])
	
	for i in range(1, nodes_by_layer.size() - 1):
		current_layer_sorting = i
		nodes_by_layer[i].sort_custom(self, "sort_layer")
	
	for i in range(nodes_by_layer.size()):
		for j in range(nodes_by_layer[i].size()):
			nodes_by_layer[i][j].position = Vector2((i * 128 + i * General_Manager.node_spacing.x), (j * 128 + j * General_Manager.node_spacing.y))
			nodes_by_layer[i][j].ref_node.canvas_location = nodes_by_layer[i][j].position
			
	for i in range(connection_display_list.size()):
		connection_display_list[i] = preload("res://Scenes/NN_Connection_Display.tscn").instance()
		connection_display_list[i].ref_connection = ref_genome.genes[i]
		add_child(connection_display_list[i])
	
	call_deferred("redefine_margin", ref_genome.agent_ref.id)

func redefine_margin(agent_id):
	if(agent_id == ref_genome.agent_ref.id):
		var temp_tl = Vector2(INF, INF)
		var temp_br = Vector2(-INF, -INF)
		for i in range(ref_genome.nodes.size()):
			if(ref_genome.nodes[i].canvas_location.x + 128 > temp_br.x):
				temp_br.x = ref_genome.nodes[i].canvas_location.x + 128
			if(ref_genome.nodes[i].canvas_location.x < temp_tl.x):
				temp_tl.x = ref_genome.nodes[i].canvas_location.x
			if(ref_genome.nodes[i].canvas_location.y + 128 > temp_br.y):
				temp_br.y = ref_genome.nodes[i].canvas_location.y + 128
			if(ref_genome.nodes[i].canvas_location.y < temp_tl.y):
				temp_tl.y = ref_genome.nodes[i].canvas_location.y
		
		ref_genome.top_left = temp_tl
		ref_genome.bottom_right = temp_br
		
		General_Manager.change_camera_limits(ref_genome.agent_ref.pop_ref)
