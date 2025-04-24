extends CanvasLayer

@onready var cursor: Cursor = get_parent()._cursor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/BtnUnidades.grab_focus()
	
	cursor.hide()
	cursor.process_mode = Node.PROCESS_MODE_DISABLED


func _on_btn_unidades_pressed() -> void:
	pass # Replace with function body.

func _on_btn_opciones_pressed() -> void:
	pass # Replace with function body.

func _on_btn_terminar_turno_pressed() -> void:
	pass # Replace with function body.

func _on_btn_cerrar_pressed() -> void:
	cursor.process_mode = Node.PROCESS_MODE_INHERIT
	cursor.reset_cursor()
	cursor.show()
	queue_free()
