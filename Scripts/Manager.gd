extends Node2D

# I don't know how to make games without a singleton (yet)
# Behold: my singleton!

var tooltips := [] # An array for every active tooltip.
var identities := [] # An array that holds an identifyer for every tooltip. If it's a node, it'll hold a 0, and if it's a connection, it'll hold a 1 in the same position as the array above.
var texts := [] # An array that holds the text for each tooltip.
# I could've made a 3D array, but that would mess my head up.
var population_ref : NN_Population = null # There's a global reference to the population, AKA the entire NN.

var rng = RandomNumberGenerator.new() # The RNGsus

var node_spacing := Vector2(64, 32) # The margin of each node. I don't know how to do it with Control nodes.
var node_size := Vector2(128, 128) # The size of each node. Same thing.

var max_min_zoom := Vector2(2.5937424601, 0.38554328942953174736440364447886) # Stores the minimum and the maximum camera zoom. Don't ask why it's done here. I do not know.

# I use signals to have every part of the game link together.
# As the connect() function requires a reference to both scripts anyway, I just put it in the singleton, so I can connect them easily.
signal change_tooltip_text(text)
signal show_tooltip()
signal hide_tooltip()
signal rerender(node)
signal redraw()
signal element_click(network, num, ele)
signal finished_loading_NN()
signal agent_added()

# I don't know why I'm making changes to the camera here.
#Todo:Isolate the camera stuff from the singleton.
var camera : Camera2D = null
var global_tl = Vector2(INF, INF)
var global_br = Vector2(-INF, -INF)

func _init():
	rng.randomize()

# I emit the signal to actually start rendering the NN after it finishes loading.
func finished_loading_NN(NN):
	# Only then it references the Population.
	population_ref = NN
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
# This will move. One day.
func change_camera_limits(pop : NN_Population):
	var tl = Vector2(INF, INF)
	var br = Vector2(-INF, -INF)
	for i in pop.pop:
		if(i.brain.bottom_right.x + i.relative_position.x > br.x):
			br.x = i.brain.bottom_right.x + i.relative_position.x
		if(i.brain.top_left.x + i.relative_position.x < tl.x):
			tl.x = i.brain.top_left.x + i.relative_position.x
		if(i.brain.bottom_right.y + i.relative_position.y > br.y):
			br.y = i.brain.bottom_right.y + i.relative_position.y
		if(i.brain.top_left.y + i.relative_position.y < tl.y):
			tl.y = i.brain.top_left.y + i.relative_position.y
	
	global_br = br
	global_tl = tl
	
	camera.limit_left = int(global_tl.x) - (camera.screensize.x / 4)
	camera.limit_top = int(global_tl.y) - (camera.screensize.y / 4)
	camera.limit_right = int(global_br.x) + (camera.screensize.x * 4)
	camera.limit_bottom = int(global_br.y) + (camera.screensize.y / 4)
	
	var screen = tl.direction_to(global_br) * tl.distance_to(global_br)
	if screen.x < camera.screensize.x:
		camera.limit_left -= (camera.screensize.x - screen.x) / 2
		camera.limit_right += (camera.screensize.x - screen.x) / 2
	if screen.y < camera.screensize.y:
		camera.limit_top -= (camera.screensize.y - screen.y) / 2
		camera.limit_bottom += (camera.screensize.y - screen.y) / 2

	max_min_zoom.x = (max(screen.x, screen.y) / camera.screensize.y) / 2

# This is probably not optimal, but oh well...
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
