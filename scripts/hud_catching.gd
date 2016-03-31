
extends CanvasLayer

var screensize = Vector2(960, 540)


func hide():
	get_node("Container").hide()


func show():
	get_node("Container").show()


func set_fish_energy(n, maxn):
	get_node("Container/Fish Energy").set_max(maxn)
	get_node("Container/Fish Energy").set_value(n)


func set_line_energy(n):
	get_node("Container/Line Energy").set_value(n)


func set_pos(pos):
	var container = get_node("Container")
	pos.x = clamp(pos.x, 100, screensize.x - 100)
	pos.y = clamp(pos.y, 100, screensize.y - 100)
	container.set_pos(pos - Vector2(100, 100))
	container.set_size(Vector2(200, 200))


func set_arrow_ang(vec):
	if vec != Vector2():
		var ang = atan2(vec.x, vec.y)
		get_node("Container/Arrow").show()
		get_node("Container/Arrow").set_rot(ang)
	else:
		get_node("Container/Arrow").hide()


func set_player_ang(vec):
	if vec != Vector2():
		var ang = atan2(vec.x, vec.y)
		get_node("Container/PlayerArrow").show()
		get_node("Container/PlayerArrow").set_rot(ang)
	else:
		get_node("Container/PlayerArrow").hide()


func _ready():
	hide()


