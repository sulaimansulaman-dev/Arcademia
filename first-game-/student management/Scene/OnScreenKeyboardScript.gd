extends Control
class_name OnScreenKeyboard

signal key_pressed(key: String)

var current_layout: String = "letters"
var shift_on: bool = false

var layouts: Dictionary = {
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

var buttons: Array[Button] = []
var active_lineedit: LineEdit = null

func _ready():
	collect_buttons()
	update_button_texts()
	register_lineedits()

# 🔹 Collect all buttons in the keyboard
func collect_buttons():
	buttons.clear()
	for row in $Rows.get_children():
		for btn in row.get_children():
			if btn is Button:
				var b: Button = btn
				buttons.append(b)
				b.set_meta("key_value", b.text)
				b.pressed.connect(func(): _on_key_pressed(b.get_meta("key_value") as String))

# 🔹 Update text on buttons depending on layout + shift
func update_button_texts():
	for row_index in range($Rows.get_child_count()):
		var row = $Rows.get_child(row_index)
		for col_index in range(row.get_child_count()):
			var btn: Button = row.get_child(col_index)
			if row_index < layouts[current_layout].size() and col_index < layouts[current_layout][row_index].size():
				var key: String = layouts[current_layout][row_index][col_index]
				btn.set_meta("key_value", key)
				match key:
					"SPACE": btn.text = "␣"
					"BACKSPACE": btn.text = "⌫"
					"ENTER": btn.text = "↵"
					"SHIFT": btn.text = "⇧"
					_: btn.text = key.to_upper() if shift_on else key.to_lower()

# 🔹 Find all LineEdits in AvatarCreation and connect them
func register_lineedits():
	var parent = get_parent()  # AvatarCreation
	for child in parent.get_children():
		if child is LineEdit:
			child.focus_entered.connect(func(): active_lineedit = child)

# 🔹 Handle key presses
func _on_key_pressed(key: String):
	if active_lineedit == null:
		return

	var pos = active_lineedit.caret_column

	match key:
		"SPACE":
			active_lineedit.text = active_lineedit.text.substr(0,pos) + " " + active_lineedit.text.substr(pos)
			active_lineedit.caret_column = pos + 1
		"BACKSPACE":
			if pos > 0:
				active_lineedit.text = active_lineedit.text.substr(0,pos-1) + active_lineedit.text.substr(pos)
				active_lineedit.caret_column = pos - 1
		"ENTER":
			active_lineedit.text = active_lineedit.text.substr(0,pos) + "\n" + active_lineedit.text.substr(pos)
			active_lineedit.caret_column = pos + 1
		"SHIFT":
			shift_on = !shift_on
			update_button_texts()
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
			var ch = key.to_upper() if shift_on else key.to_lower()
			active_lineedit.text = active_lineedit.text.substr(0,pos) + ch + active_lineedit.text.substr(pos)
			active_lineedit.caret_column = pos + 1
			if shift_on:
				shift_on = false
				update_button_texts()
