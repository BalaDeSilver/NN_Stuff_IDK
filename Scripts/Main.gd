extends Node2D

"""
var node_debug : NN_Node
var node_debug2 : NN_Node
var connection_debug

# Called when the node enters the scene tree for the first time.
func _ready():
	node_debug = NN_Node.new(0)
	node_debug2 = NN_Node.new(1)
	connection_debug = NN_Connection.new(node_debug, node_debug2, 1)
	
	var node_display_debug = get_node("NN_Node_Display")
	var node_display_debug2 = get_node("NN_Node_Display2")
	var connection_display_debug = get_node("NN_Connection_Display")
	
	node_debug.canvas_location = node_display_debug.position + (get_node("NN_Node_Display/NN_Node_Sprite").texture.get_size() / 2)
	node_debug2.canvas_location = node_display_debug2.position + (get_node("NN_Node_Display2/NN_Node_Sprite").texture.get_size() / 2)
	node_display_debug.ref_node = node_debug
	node_display_debug2.ref_node = node_debug2
	connection_display_debug.ref_connection = connection_debug
"""

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
