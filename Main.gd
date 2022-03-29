extends Node2D

onready var main_line = $MainLine
onready var curved_line = $CurvedLine
onready var draw_timer = $CurveDrawTimer
onready var control_points = $Points

var points : Array
var curve_drawn = false
var is_dragging = false
var temp_bool = false
var cur_point
var finished_drag = false

func _ready():
	draw_main_line()
	temp_bool = is_dragging

func _process(_delta):
	if is_dragging:
		var p = control_points.get_child(control_points.get_children().find(cur_point))
		p.rect_global_position = get_global_mouse_position()
		draw_main_line()
		if curve_drawn:
			curve_drawn = true
			draw_timer.start()
	
	# if finished_drag:
	# 	draw_timer.start()

	if !draw_timer.is_stopped():
		draw_curve(1)
		draw_timer.stop()
	
func _input(event):
	var p = can_drag()
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT :
		if event.pressed and p:
			is_dragging = true
			cur_point = p
		else:
			is_dragging = false
			cur_point = null
			finished_drag = true
			yield(get_tree().create_timer(0.25), "timeout")
			finished_drag = false

func can_drag():
	for p in control_points.get_children():
		if get_global_mouse_position().distance_to(p.rect_global_position) < 16:
			return p
	return false

func draw_main_line():
	main_line.clear_points()
	for p in control_points.get_children():
		main_line.add_point(p.rect_position)
	points = main_line.points
	
func draw_curve(num):
	curved_line.clear_points()
	var i = 0.00
	while i < num:
		var curve_points = bezier(points, i)
		for p in curve_points:
			curved_line.add_point(p)
		i += 0.001

func bezier(ps, t):
	# var l1 = (1 - t) * p1 + t * p2
	# var l2 = (1 - t) * p2 + t * p3
	# var q1 = (1 - t) * l1 + t * l2

	var ls = []
	var qs = []
	var cs = []
	var zs = []
	var xs = []

	for p1 in ps.size() - 1:
		var p2 = p1 + 1
		if ps[p2] is Vector2:
			var l = ps[p1].linear_interpolate(ps[p2], t)
			ls.append(l)
	
	for l1 in ls.size()- 1:
		var l2
		if ls[l1 + 1]:
			l2 = l1 + 1
		var q = ls[l1].linear_interpolate(ls[l2], t)
		qs.append(q)
	
	for q1 in qs.size() - 1:
		var q2
		if qs[q1 + 1]:
			q2 = q1 + 1
		var c = qs[q1].linear_interpolate(qs[q2], t)
		cs.append(c)
	
	for c1 in cs.size() - 1:
		var c2
		if cs[c1 + 1]:
			c2 = c1 + 1
		var z = cs[c1].linear_interpolate(cs[c2], t)
		zs.append(z)

	for z1 in zs.size() - 1:
		var z2
		if zs[z1 + 1]:
			z2 = z1 + 1
		var x = zs[z1].linear_interpolate(zs[z2], t)
		xs.append(x)
	
	if xs.size() > 0:
		return xs
	elif zs.size() > 0:
		return zs
	elif cs.size() > 0:
		return cs
	elif qs.size() > 0:
		return qs
	elif ls.size() > 0:
		return ls

	# return q1


func _on_DrawButton_pressed():
	if !curve_drawn:
		curve_drawn = true
		draw_timer.start()

func _on_ClearButton_pressed():
	if curve_drawn:
		curved_line.clear_points()
		curve_drawn = false
