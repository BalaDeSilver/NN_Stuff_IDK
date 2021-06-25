extends Node2D

# I don't know how to make games without a singleton (yet)
# Behold: my singleton!
var save_file := ""

var tooltips := [] # An array for every active tooltip.
var identities := [] # An array that holds an identifyer for every tooltip. If it's a node, it'll hold a 0, and if it's a connection, it'll hold a 1 in the same position as the array above.
var texts := [] # An array that holds the text for each tooltip.
# I could've made a 3D array, but that would mess my head up.
var population_ref : NN_Population = null # There's a global reference to the population, AKA the entire NN.
var pop_display = null # Also a global reference to the display, because I want to load the game.

var node_spacing := Vector2(64, 32) # The margin of each node. I don't know how to do it with Control nodes.
var node_size := Vector2(128, 128) # The size of each node. Same thing.

# I use signals to have every part of the game link together.
# As the connect() function requires a reference to both scripts anyway, I just put it in the singleton, so I can connect them easily.
signal new_NN()
signal change_tooltip_text(text)
signal show_tooltip()
signal hide_tooltip()
signal rerender(node)
signal redraw()
signal element_click(network, num, ele)
signal finished_loading_NN()
signal agent_added()
signal update_camera(pop)

# I emit the signal to actually start rendering the NN after it finishes loading,
# so it actually has data to render.
func finished_loading_NN(NN, disp):
	# Only then it references the Population.
	population_ref = NN
	pop_display = disp
	emit_signal("finished_loading_NN")

# The actual ID of the string is its own text.
# Yes, it's slow, but it saves on me actually making good code.
#                                          0 = node; 1 = connection
func add_tooltip(text : String, ref : int, identifyer : int):
	if(!tooltips.has(ref) or identifyer != identities[tooltips.find(ref)]):
		tooltips.append(ref)
		identities.append(identifyer)
		texts.append(text)
		emit_signal("show_tooltip")
	
	emit_signal("change_tooltip_text", text)

func remove_tooltip(text : String):
	if (texts.find(text) == -1):
		emit_signal("hide_tooltip")
	else:
		tooltips.remove(texts.find(text))
		identities.remove(texts.find(text))
		texts.erase(text)
		if(tooltips.size() == 0):
			emit_signal("hide_tooltip")
		else:
			emit_signal("change_tooltip_text", texts.back())

func save_game(path):
	var file = File.new()
	file.open(path, File.WRITE)
	
	file.store_var(population_ref.pop)
	
	file.close()
	return 0

func load_game(path):
	var file = File.new()
	file.open(path, File.READ)
	print("I didn't implement a Load function yet, sorry...")
	#population_ref.pop.queue_free()
	#population_ref.pop = file.get_var(true)
	
	file.close()
	redraw()
	return 0

# This is probably not optimal, but oh well...
func new_NN():
	emit_signal("new_NN")

func change_camera_limits(pop : NN_Population):
	emit_signal("update_camera", pop)

func redraw():
	emit_signal("redraw")

func add_agent():
	emit_signal("agent_added")

func node_picked():
	emit_signal("hide_tooltip")

func node_moved(agent_id : int):
	emit_signal("rerender", agent_id)

func element_clicked(genome : NN_Genome, num : int, ele : int):
	emit_signal("element_click", genome, num, ele)
