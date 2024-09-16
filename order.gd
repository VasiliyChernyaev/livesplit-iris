extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var num: int:
	set(value): 
		num = clamp(value, 0, 12)

func _on_decrease_pressed() -> void:
	num = int($Number.text)
	num -= 1
	$Number.text = str(num)

func _on_increase_pressed() -> void:
	num = int($Number.text)
	num += 1
	$Number.text = str(num)
