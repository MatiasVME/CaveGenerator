# MIT License
#
# Copyright (c) 2018 Matías Muñoz Espinoza (Plugin adaptation)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

extends Node

export (bool) var debug = false

var size = Vector2()
var map = []
var tilemap
var fill_wall_percent = 50

# Métodos públicos y Setters/Getters
#

func _ready():
	randomize()

func generate_walls(_tilemap, _smooth_iteration = 0, _sizev = Vector2(35, 35), _delete_floor = false, _fill_wall_percent = 50):
	tilemap = _tilemap
	size = _sizev
	fill_wall_percent = _fill_wall_percent
	
	base_algoritm()
	for i in _smooth_iteration:
		smooth()
	
	if _delete_floor:
		delete_floor()
	
	return tilemap

# Recibe un tilemap y el tamaño y devuelve un terreno
# con variaciones, el tile 0 es el terreno común y los
# demás son variaciones.
func generate_floor_map(tilemap, sizev):
	# Cantidad de tipos de tiles que hay en el tilemap
	var tile_type_amount = tilemap.tile_set.get_tiles_ids().size()
	print(tile_type_amount)
	
	for i in sizev.y:
		for j in sizev.x:
			if randi() % 10 == 1:
				tilemap.set_cellv(Vector2(j, i), rand_range(1, tile_type_amount))
			else:
				tilemap.set_cellv(Vector2(j, i), 0)

func add_border(border_tile_num):
	for i in size.y:
		for j in size.x:
			if j == 0 or i == 0 or j == size.y - 1 or i == size.x - 1:
				tilemap.set_cellv(Vector2(i, j), border_tile_num)

func smooth():
	# new map to apply changes
	var new_map = []
	new_map.resize(size.x * size.y)
	
	for e in range(map.size()): # copy old array
		new_map[e] = map[e]
	
	# we need to skip borders of screen
	for y in range(1,size.y -1):
		for x in range(1,size.x - 1):
			var i = y * size.x + x
			if map[i] == 1: # if it was a wall
				if touching_walls(Vector2(x,y)) >= 4: # and 4 or more of its eight neighbors were walls
					new_map[i] = 1 # it becomes a wall
				else:
					new_map[i] = 0
			elif map[i] == 0: # if it was empty
				if touching_walls(Vector2(x,y)) >= 5: # we need 5 or neighbors
					new_map[i] = 1
				else:
					new_map[i] = 0
	
	map = new_map # apply new array
	
	return update_map()

# Privados
#

# set tiles in Tilemap to match map array
func update_map():
	for y in range(size.y):
		for x in range(size.x):
			var i = y * size.x + x
			
			tilemap.set_cell(x, y, map[i])
	
	return tilemap

func base_algoritm():
	map.resize(size.x * size.y)
	for y in range(size.y):
		for x in range(size.x):
			var i = y * size.x + x # index of current tile
			
			# fill map with random tiles
			if randi() % 101 < fill_wall_percent or x == 0 or x == size.x - 1 or y == 0 or y == size.y - 1:
				map[i] = 1 # wall
			else:
				map[i] = 0 # empty
	# draw the map
	update_map()

# return count of touching walls 
func touching_walls(point):
	var result = 0
	for y in [-1,0,1]:
		for x in [-1,0,1]:
			if x == 0 and y == 0: # we don't want to count tested point
				continue
			var i = (y + point.y) * size.x + (x + point.x)
			if map[i] == 1:
				result += 1
	return result

func delete_floor():
	for i in size.y:
		for j in size.x:
			if tilemap.get_cellv(Vector2(j,i)) == 0:
				tilemap.set_cellv(Vector2(j, i), -1)

func debug(message, something1 = "", something2 = ""):
	if debug:
		print("[CaveGenerator] ", message, " ", something1, " ", something2)
