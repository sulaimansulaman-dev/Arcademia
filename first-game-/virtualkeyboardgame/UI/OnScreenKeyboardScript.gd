extends Control
class_name OnScreenKeyboard

signal key_pressed(key: String)

# Track current layout and shift state
var current_layout := "letters"
var shift_on := false

# Layout definitions
var layouts = {
	"letters": [
		["Q","W","E","R","T","Y","U","I","O","P"],
		["A","S","D","F","G","H","J","K","L"],
		["SHIFT","Z","X","C","V","B","N","M","BACKSPACE"],
		["123","SPACE",".","@","ENTER"]
	],
	"numbers": [
		["1","2","3","4","5","6","7","8","9","0"],
		["-","/",":",";","(",")","$","&","@"],
		["ABC",".",",","?","!","'","\"","+","BACKSPACE"],
		["#+=","SPACE",".","@","ENTER"]
	],
	"symbols": [
		["[","]","{","}","#","%","^","*","+","="],
		["_","\\","|","~","<",">","€","£","¥"],
		["123",".",",","?","!","'","\"","+","BACKSPACE"],
		["ABC","SPACE",".","@","ENTER"]
	]
}

# Store collected buttons
var buttons: Array[Button] = []

# Label where text will be shown (adjust path for your scene)
@onready var output_label: Label = $OutputLabel

# -------------------- READY --------------------
func _ready():
	collect_buttons()
	update_button_texts()

# -------------------- COLLECT BUTTONS --------------------
func collect_buttons():
	buttons.clear()
	for row in $Rows.get_children():
		for btn in row.get_children():
			if btn is Button:
				buttons.append(btn)
				btn.set_meta("key_value", btn.text)
				btn.pressed.connect(func():
					_on_key_pressed(btn.get_meta("key_value"))
				)

# -------------------- UPDATE BUTTON TEXTS --------------------
func update_button_texts():
	var row_index = 0
	for row in $Rows.get_children():
		var col_index = 0
		for btn in row.get_children():
			if row_index < layouts[current_layout].size() and col_index < layouts[current_layout][row_index].size():
				var key = layouts[current_layout][row_index][col_index]
				btn.set_meta("key_value", key)
				match key:
					"SPACE": btn.text = "␣"
					"BACKSPACE": btn.text = "⌫"
					"ENTER": btn.text = "↵"
					"SHIFT": btn.text = "⇧"
					_: btn.text = key.to_upper() if shift_on else key.to_lower()
				col_index += 1
		row_index += 1

# -------------------- HANDLE KEY PRESSES --------------------
func _on_key_pressed(key: String):
	match key:
		"SPACE":
			_add_char(" ")
		"BACKSPACE":
			_remove_char()
		"ENTER":
			_add_char("\n")
		"SHIFT":
			toggle_shift()
		"123":
			current_layout = "numbers"
			update_button_texts()
		"ABC":
			current_layout = "letters"
			update_button_texts()
		"#+=":
			current_layout = "symbols"
			update_button_texts()
		_:
			var output = key.to_upper() if shift_on else key.to_lower()
			_add_char(output)
			if shift_on:
				shift_on = false
				update_button_texts()

# -------------------- ADD / REMOVE CHAR --------------------
func _add_char(ch: String):
	output_label.text += ch
	emit_signal("key_pressed", ch)

func _remove_char():
	if output_label.text.length() > 0:
		output_label.text = output_label.text.substr(0, output_label.text.length() - 1)
	emit_signal("key_pressed", "BACKSPACE")

# -------------------- TOGGLE SHIFT --------------------
func toggle_shift():
	shift_on = !shift_on
	update_button_texts()
