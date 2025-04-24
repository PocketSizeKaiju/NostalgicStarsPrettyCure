extends CanvasLayer

@onready var cursor: Cursor = get_parent()._cursor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/BtnAtacar.grab_focus()
	
	cursor.hide()
	cursor.process_mode = Node.PROCESS_MODE_DISABLED


func _on_btn_atacar_pressed() -> void:
	pass # Replace with function body.

func _on_btn_items_pressed() -> void:
	pass # Replace with function body.

func _on_btn_intercambio_pressed() -> void:
	pass # Replace with function body.

func _on_btn_esperar_pressed() -> void:
	#TBA Estados
	
	cerrar_menu_devolder_cursor()

func _on_btn_cancelar_pressed() -> void:
	#Resetear posicion unidades
	get_parent()._resetear_unidad()
	cerrar_menu_devolder_cursor()


func cerrar_menu_devolder_cursor():
	get_parent()._limpiar_unidad_activa()
	cursor.process_mode = Node.PROCESS_MODE_INHERIT
	cursor.reset_cursor()
	cursor.show()
	queue_free()
