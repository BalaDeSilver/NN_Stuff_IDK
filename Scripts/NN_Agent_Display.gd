extends Node2D

var ref_agent : NN_Agent = null
var network_display = null

func _ready():
	network_display = preload("res://Scenes/NN_Network_Display.tscn").instance()
	network_display.ref_genome = ref_agent.brain
	add_child(network_display)
	
	call_deferred("reposition_agent")
	General_Manager.connect("redraw", self, "redraw")

func redraw():
	call_deferred("reposition_agent")

func reposition_agent():
	if(ref_agent.id != 0):
		var br = ref_agent.pop_ref.pop[ref_agent.id - 1].brain.bottom_right + ref_agent.pop_ref.pop[ref_agent.id - 1].relative_position

		position.y = br.y + 32
		ref_agent.relative_position = position
		General_Manager.node_moved(ref_agent.id)
	else:
		position.y = 0
		ref_agent.relative_position = position
		General_Manager.node_moved(ref_agent.id)
