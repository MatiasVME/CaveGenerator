extends Node2D

func _ready():
	$CaveGenerator.map_generator($TileMap, 6)
