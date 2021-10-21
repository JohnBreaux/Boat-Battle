extends TextEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	var _errno = MessageBus.connect("print_console", self, "_on_Debug_print_text")
	grab_focus()


func _on_Debug_print_text(text):
	insert_text_at_cursor(text)


func _on_Debug_clear_out():
	cursor_set_line(0)
	cursor_set_column(0)
	text = "";
