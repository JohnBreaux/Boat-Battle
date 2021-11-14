extends Node

# Ignore "unused signal" warnings in this class
# warning-ignore-all:unused_signal

# Ask for a scene change
signal change_scene(scene_name)

signal start_tcsn(scene_tcsn_name)
# Ask to kill scene
signal kill_scene(scene_name)
# Ask to list active scenes
signal list_scenes()
# Ask to quit the game
signal quit
# Ask to return to title screen
signal return_to_title

# Ask to print a string to debug console
signal print_console(string)
