extends CanvasLayer

var timer_text = "Timer: %s"
@export var timer: int
var timer_delta = 0
var game_active = false
var timer_label

signal start_game

func _ready():
	timer_label = $TimerLabel
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_active:
		timer_delta += delta
		var _time = timer + 1 - timer_delta
		if _time < 0:
			var main = get_tree().get_root().get_node("Main")
			main.end_game()
		timer_label.text = timer_text % str(int(_time))


func game_over(won=false):
	game_active = false
	timer_delta = 0
	if won:
		$Title.text = "<CONGRATULATIONS>"
		$SubTitle.text = "{YOU_WON!}"
	$TimerLabel.hide()
	$Title.show()
	$SubTitle.show()


func _input(event):
	if event is InputEventKey and event.pressed and game_active == false:
		$TimerLabel.show()
		$Title.hide()
		$SubTitle.hide()
		start_game.emit()
		game_active = true

