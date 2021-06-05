extends Node2D

var ref_genome : NN_Genome = null
var nodes_display_list : Array = []
var connection_display_list : Array = []
var nodes_by_display : Array = []

var top_left : Vector2 = Vector2(0, 0)
var bottom_right : Vector2 = Vector2(0, 0)

func _ready():
	ref_genome = NN_Genome.new(2, 3, false)
	nodes_display_list.resize(ref_genome.nodes.size())
	connection_display_list.resize(ref_genome.genes.size())
	
	nodes_by_display.resize(ref_genome.layers)
	for i in range(nodes_by_display.size()):
		nodes_by_display[i] = []
	
	for i in range(nodes_display_list.size()):
		nodes_display_list[i] = preload("res://Scenes/NN_Node_Display.tscn").instance()
		add_child(nodes_display_list[i])
		nodes_display_list[i].z_index = 1
		nodes_display_list[i].ref_node = ref_genome.nodes[i]
		
		nodes_by_display[nodes_display_list[i].ref_node.layer].append(nodes_display_list[i])
	
	for i in range(nodes_by_display.size()):
		for j in range(nodes_by_display[i].size()):
			nodes_by_display[i][j].position = Vector2((i * 128 + i * 32), (j * 128 + j * 32))
	
	for i in range(connection_display_list.size()):
		connection_display_list[i] = preload("res://Scenes/NN_Connection_Display.tscn").instance()
		add_child(connection_display_list[i])
		connection_display_list[i].ref_connection = ref_genome.genes[i]
	
	ref_genome.generate_network()
	
	General_Manager.connect("rerender", self, "redefine_margin")
	call_deferred("redefine_margin", 0)
	
	General_Manager.networks.append(self)

func redefine_margin(_num):
	var temp_tl = Vector2(INF, INF)
	var temp_br = Vector2(-INF, -INF)
	for i in ref_genome.nodes:
		if(i.canvas_location.x > temp_br.x):
			temp_br.x = i.canvas_location.x + 128
		if(i.canvas_location.x < temp_tl.x):
			temp_tl.x = i.canvas_location.x
		if(i.canvas_location.y > temp_br.y):
			temp_br.y = i.canvas_location.y + 128
		if(i.canvas_location.y < temp_tl.y):
			temp_tl.y = i.canvas_location.y
	
	General_Manager.change_camera_limits(temp_tl, temp_br, ref_genome.number)
