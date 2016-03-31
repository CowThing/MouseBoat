
extends RigidBody

var rippleeffect = preload("res://scenes/effects/ripple.scn")

const turnspeed = 5
const movespeed = 15

const STATE_NONE = -1
const STATE_MOVE = 0
const STATE_CASTING = 1
const STATE_FISHING = 2
const STATE_CATCHING = 3

var last_state = -1
var current_state = 0
var next_state = 0

onready var spawntransform = get_transform()

var casting_aim = Vector3()
var casting_time = 0

var lineenergy = 100

var can_spawn_ripple = true

var bobber

onready var animation = get_node("AnimationTreePlayer")
onready var HUD = get_node("HUD Catching")


func _ready():
	set_process_input(true)
	set_process(true)
	set_fixed_process(true)
	get_node("Ambient").play("pondambient")


func reset_pos():
	yield(get_tree(), "idle_frame")
	set_transform(spawntransform)


func set_bobber(obj):
	bobber = weakref(obj)


func get_bobber():
	if bobber:
		return bobber.get_ref()
	return bobber


func set_state(st):
	next_state = st


func line_add_energy(n):
	lineenergy = clamp(lineenergy + n, 0, 100)


func _integrate_forces(state):
	var lv = state.get_linear_velocity()
	var av = state.get_angular_velocity()
	var step = state.get_step()
	
	var moveF = Input.is_action_pressed("MOVE_FORWARD")
	var moveL = Input.is_action_pressed("MOVE_LEFT")
	var moveR = Input.is_action_pressed("MOVE_RIGHT")
	var moveB = Input.is_action_pressed("MOVE_BACK")
	
	if current_state == STATE_NONE:
		lv = Vector3()
		av = Vector3()
	
	var lvlen = lv.length()
	if current_state == STATE_MOVE:
		
		if moveF:
			var d = get_transform().basis.z
			lv += d * movespeed * step
			
		elif moveB:
			if lvlen <= movespeed * 0.2:
				var d = -get_transform().basis.z
				lv += d * movespeed * 0.2 * step
				
				if lvlen >= movespeed * 0.2:
					lv = lv.normalized() * movespeed * 0.2
		
		if moveL:
			av.y += step
		
		if moveR:
			av.y -= step
		
		av.y = clamp(av.y, -turnspeed, turnspeed)
		
		if lvlen >= movespeed:
				lv = lv.normalized() * movespeed
		
		if lvlen > 2:
			if get_node("RippleSpawn").get_time_left() <= 0:
				get_node("RippleSpawn").set_wait_time( 0.3 + ((movespeed - lvlen) / movespeed) * 0.7)
				get_node("RippleSpawn").start()
		else:
			get_node("RippleSpawn").stop()
		
	else:
		get_node("RippleSpawn").stop()
		lv -= lv * 0.9 * step
		av -= av * 0.9 * step
	
	#water moving sound
	if lvlen > 2:
		if not get_node("SFX").is_voice_active(0):
			get_node("SFX").play("movingwater", 0)
		get_node("SFX").voice_set_volume_scale_db(0, (1 - lvlen / movespeed) * -20)
		get_node("SFX").voice_set_pitch_scale(0, 0.5 + (0.5 * lvlen / movespeed))
	else:
		get_node("SFX").stop_voice(0)
	
	set_linear_velocity(lv)
	set_angular_velocity(av)


func _input(event):
	if current_state == STATE_MOVE:
		if event.type == InputEvent.MOUSE_BUTTON and event.pressed and event.button_index == BUTTON_LEFT:
			set_state(STATE_CASTING)
	
	elif current_state == STATE_CASTING:
		if event.type == InputEvent.MOUSE_BUTTON and not event.pressed and event.button_index == BUTTON_LEFT:
			set_state(STATE_FISHING)
			
			#spawn bobber
			var bi = load("res://scenes/objects/bobber.scn").instance()
			
			var mousetr = get_node("Boat/Armature/Skeleton/Rod Hand").get_global_transform()
			var bobber_pos = mousetr.origin + mousetr.basis.y * 10
			
			var bobber_shootdir = get_node("Boat/Armature/Skeleton").get_global_transform().basis.z
			
			get_parent().add_child(bi)
			bi.player = self
			bi.set_translation(bobber_pos)
			bi.apply_impulse(bi.get_translation(), Vector3(0, (casting_time / 1.25) * 20, 0) + (bobber_shootdir * (casting_time / 1.25) * 25))
			
			set_bobber(bi)
		
		if event.type == InputEvent.MOUSE_BUTTON and event.pressed and event.button_index == BUTTON_RIGHT:
			set_state(STATE_MOVE)
	
	elif current_state == STATE_FISHING:
		if event.type == InputEvent.MOUSE_BUTTON and event.pressed and event.button_index == BUTTON_LEFT:
			if get_bobber():
				get_bobber().set_hook()


func _process(delta):
	current_state = next_state
	
	if current_state == STATE_MOVE:
		if current_state != last_state:
			get_node("Boat/Armature/Skeleton").set_rotation(Vector3())
			
			casting_time = 0
			
			#animation
			animation.oneshot_node_stop("casting")
			animation.timeseek_node_seek("seek", 0)
			animation.transition_node_set_current("idle pose", 0)
	
	elif current_state == STATE_CASTING:
		if current_state != last_state:
			#animation
			animation.oneshot_node_start("casting")
			animation.transition_node_set_current("idle pose", 3)
	
	elif current_state == STATE_FISHING:
		if current_state != last_state:
			casting_time = 0
			
			#animation
			animation.oneshot_node_stop("casting")
			animation.timeseek_node_seek("seek", 0)
			animation.transition_node_set_current("idle pose", 1)
	
	elif current_state == STATE_CATCHING:
		if current_state != last_state:
			lineenergy = 100
			HUD.show()
			HUD.set_pos(get_node("Camera Pivot/Camera").unproject_position(get_bobber().get_translation()))
			
			get_node("Reel Sound Effect").start()
			
			#animtion
			animation.transition_node_set_current("idle pose", 2)
		
		#minigame time
		var moveF = Input.is_action_pressed("MOVE_FORWARD")
		var moveL = Input.is_action_pressed("MOVE_LEFT")
		var moveR = Input.is_action_pressed("MOVE_RIGHT")
		var moveB = Input.is_action_pressed("MOVE_BACK")
		var mouseLeft = Input.is_action_pressed("REEL") or Input.is_mouse_button_pressed(BUTTON_LEFT)
		
		var fish = get_bobber().get_fish()
		
		var playerang = Vector2()
		if moveF:
			playerang.y += 1
		if moveL:
			playerang.x += 1
		if moveR:
			playerang.x -= 1
		if moveB:
			playerang.y -= 1
		playerang = playerang.normalized()
		
		var linedmg = -15
		var fishdmg = -5
		
		if fish.struggle != Vector2():
			var struggleang = playerang.dot(fish.struggle)
			if struggleang >= 0.9:
				linedmg = 0
			else:
				linedmg = 20
			
			if mouseLeft:
				linedmg += 10
				fishdmg += 5
			
		else:
			if mouseLeft:
				linedmg += 20
				fishdmg += 20
		
		line_add_energy(-delta * linedmg)
		fish.add_energy(-delta * fishdmg)
		
		#update HUD
		var fishenergy = fish.energy
		HUD.set_fish_energy(fishenergy, fish.maxenergy)
		HUD.set_line_energy(100 - lineenergy)
		
		HUD.set_arrow_ang(fish.struggle)
		HUD.set_player_ang(playerang)
		
		if fishenergy <= 0:
			set_state(STATE_MOVE)
			get_node("/root/Main").show_fish(fish)
		elif lineenergy <= 0:
			set_state(STATE_MOVE)
			print("FISH LOST")
		
		if current_state != next_state:
			HUD.hide()
			get_node("Reel Sound Effect").stop()
			get_node("SFX").stop_voice(1)
	
	last_state = current_state


func _fixed_process(delta):
	if current_state == STATE_CASTING:
		casting_time = min(casting_time + delta, 1.25)
		
		#raycast
		var camera = get_node("Camera Pivot/Camera")
		var from = camera.project_ray_origin(get_viewport().get_mouse_pos())
		var to = from + camera.project_ray_normal(get_viewport().get_mouse_pos()) * 500
		
		var space_state = get_world().get_direct_space_state()
		var result = space_state.intersect_ray(from, to, [self], 2)
		
		if not result.empty():
			var mousetr = get_node("Boat/Armature/Skeleton").get_transform()
			result.position.y = 0
			mousetr = mousetr.looking_at(result.position - get_global_transform().origin, Vector3(0, 1, 0))
			mousetr *= get_global_transform().inverse()
			mousetr.origin = Vector3()
			mousetr = mousetr.rotated(Vector3(0, 1, 0), PI)
			get_node("Boat/Armature/Skeleton").set_transform(mousetr)


func _on_RippleSpawn_timeout():
	var ripple = rippleeffect.instance()
	
	var rippletr = get_global_transform()
	rippletr.origin.y = 0.1
	rippletr = rippletr.rotated(Vector3(0, 1, 0), randf() * 2 * PI)
	
	get_parent().add_child(ripple)
	ripple.set_transform(rippletr)
	ripple.set_scale(Vector3(1,1,1) * (0.5 + randf()))
	ripple.get_node("Sprite3D").set_frame(randi()%3)


func _on_Reel_Sound_Effect_timeout():
	get_node("Reel Sound Effect").set_wait_time(2 + randf() * 0.5)
	get_node("Reel Sound Effect").start()
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		get_node("SFX").play("reel", 1)
		get_node("SFX").voice_set_pitch_scale(1, 0.9 + randf() * 0.2)


