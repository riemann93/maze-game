extends CanvasLayer

var score_text = "Score: "

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func update_score(score):
	$ScoreLabel.text = score_text + str(score)
