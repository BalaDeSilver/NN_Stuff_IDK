extends Node2D

var ref_agent : NN_Agent = null # Holds the reference to the agent itself, as, currently, it is actually a child of another node.
var brain_display = null # Holds an instance of a scene that displays the agent's brain.

func _ready():
	brain_display = preload("res://Scenes/NN_Genome_Display.tscn").instance()
	brain_display.ref_genome = ref_agent.brain
	add_child(brain_display)
	
	General_Manager.connect("redraw", self, "redraw")
	call_deferred("reposition_agent")

func redraw():
	call_deferred("reposition_agent")

# Repositions the agent as necessary.
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
