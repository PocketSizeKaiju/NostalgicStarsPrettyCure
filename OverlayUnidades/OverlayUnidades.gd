class_name OverlayUnidades
extends TileMapLayer


func dibujar_celdas_caminables(celdas: Array) -> void:
	#clear()
	for celda in celdas:
		set_cell(celda, 0, Vector2i(0,0))

func dibujar_celdas_atacables(celdas: Array) -> void:
	for celda in celdas:
		set_cell(celda, 1, Vector2i(0,0))
