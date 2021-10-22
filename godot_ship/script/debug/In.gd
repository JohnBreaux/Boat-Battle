extends LineEdit

func _on_Debug_clear_in():
	clear()

func _on_Debug_history_event(history):
	text = history;
