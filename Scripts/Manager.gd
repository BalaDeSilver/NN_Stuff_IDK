extends Node2D

var tooltips : Array = []
var identities : Array = []
var texts : Array = []
var population_ref : NN_Population = null

var rng = RandomNumberGenerator.new()

var node_spacing := Vector2(64, 32)

signal change_tooltip_text(text)
signal show_tooltip
signal hide_tooltip
signal rerender(node)
signal redraw
signal element_click(network, num, ele)
signal finished_loading_NN

var camera : Camera2D = null
var global_tl = Vector2(INF, INF)
var global_br = Vector2(-INF, -INF)

func _init():
	rng.randomize()

func finished_loading_NN(NN):
	population_ref = NN
	emit_signal("finished_loading_NN")
#                                          0 = node; 1 = connection
func add_tooltip(text : String, ref : int, identifyer : int):
	if(!tooltips.has(ref)):
		tooltips.append(ref)
		identities.append(identifyer)
		texts.append(text)
		emit_signal("show_tooltip")
	elif(identifyer != identities[tooltips.find(ref)]):
		tooltips.append(ref)
		identities.append(identifyer)
		texts.append(text)
		emit_signal("show_tooltip")
	emit_signal("change_tooltip_text", text)

func remove_tooltip(text : String):
	tooltips.remove(texts.find(text))
	identities.remove(texts.find(text))
	texts.erase(text)
	if(tooltips.size() == 0):
		emit_signal("hide_tooltip")
	else:
		emit_signal("change_tooltip_text", texts.back())

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
	
	camera.limit_left = int(global_tl.x) - (camera.screensize.x * 0.25)
	camera.limit_top = int(global_tl.y) - (camera.screensize.y * 0.25)
	camera.limit_right = int(global_br.x) + (camera.screensize.x)
	camera.limit_bottom = int(global_br.y) + (camera.screensize.y)
	
	var screen = tl.direction_to(global_br) * tl.distance_to(global_br)
	if screen.x < camera.screensize.x:
		camera.limit_left -= (camera.screensize.x - screen.x) / 2
		camera.limit_right += (camera.screensize.x - screen.x) / 2
	if screen.y < camera.screensize.y:
		camera.limit_top -= (camera.screensize.y - screen.y) / 2
		camera.limit_bottom += (camera.screensize.y - screen.y) / 2

func redraw():
	emit_signal("redraw")

func node_picked():
	emit_signal("hide_tooltip")

func node_moved(agent_id : int):
	emit_signal("rerender", agent_id)

func element_clicked(genome : NN_Genome, num : int, ele : int):
	emit_signal("element_click", genome, num, ele)
