extends KinematicBody2D

# Constants
const UP = Vector2(0,-1)
const GRAVITY = 20
const SPEED = 20000
const JUMP_HEIGHT = -650

# Variables
var motion = Vector2()
var dash = false
var timer:Timer
var sequence = []
var moves = {
	"dash-right"  : ["right", "right"],
	"dash-left" : ["left", "left"],
}

# When our Hero is ready
func _ready():
	$Sprite.flip_h = false
	_config_timer()

func _physics_process(delta):
	var speed = SPEED * delta
	motion.y += GRAVITY

	if Input.is_action_pressed("ui_left"):
		$Sprite.flip_h = true
		$Sprite.play('walk')
		
		if dash:
			speed = speed*2.5
			$Sprite.play('dash')
						
		motion.x = -speed
	elif  Input.is_action_pressed("ui_right"):
		$Sprite.flip_h = false
		$Sprite.play('walk')
		
		if dash:
			speed = speed*2.5
			$Sprite.play('dash')
			
		motion.x = speed
	else:
		$Sprite.play('idle')
		motion.x = 0
		dash=false

	if is_on_floor():
		if Input.is_action_pressed("ui_jump"):
			motion.y = JUMP_HEIGHT
	else:
		$Sprite.play('jump')

	motion = move_and_slide(motion, UP)

# Timer configuration
func _config_timer():
	timer = Timer.new()
	add_child(timer)
	
	timer.wait_time = 0.2 # Wait time in seconds
	timer.one_shot = true # Run timer just one time
	
	timer.connect("timeout", self, "on_timeout")

# Runs every time timer get timeout
func on_timeout():
	# verify special sequence
	verify_sequence( sequence )		
	# Clear the sequence
	sequence = []
	
# Verify the sequence
func verify_sequence( sequence ):
	for move_name in moves.keys():
		if sequence == moves[move_name]:
			_play_action( move_name )

# Start the special movement
func _play_action( action ):
	if action.substr(0, 4) == "dash":
		dash=true # Turns the dash on
		
# Listen the input event
func _input(event):
	# Prevent wrong events
	if not event is InputEventKey:
		return
	if not event.is_pressed():
		return

	if event.is_action_pressed("ui_right"):
		sequence.push_back( "right" )
	elif event.is_action_pressed("ui_left"):
		sequence.push_back( "left" )
		
	timer.start()
