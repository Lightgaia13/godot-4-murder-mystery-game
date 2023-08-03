extends CanvasLayer



func _ready():
	self.hide()


func _unhandled_input(event):
	if not get_parent().is_multiplayer_authority(): return
	
	#open pause menu
	if Input.is_action_just_pressed("pause") and not self.visible:
		self.show()
		if get_parent().has_method("enable_input"):
			get_parent().enable_input(false)
	
	
	#close pause menu
	elif Input.is_action_just_pressed("pause") and self.visible:
		self.hide()
		if get_parent().has_method("enable_input"):
			get_parent().enable_input(true)


func _on_username_input_text_submitted(new_text):
	if get_parent().has_method("change_username"):
		get_parent().rpc("change_username", new_text)




func _on_quit_pressed():
	get_tree().quit()
