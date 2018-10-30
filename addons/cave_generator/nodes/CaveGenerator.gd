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

var size
var map = []
var tilemap
var fill_percent

# Métodos públicos y Setters/Getters
#

func _ready():
	randomize()

func map_generator(_tilemap, _smooth_iteration = 0, _fill_percent = 30, _size = Vector2(35, 35)):
	tilemap = _tilemap
	size = _size
	fill_percent = _fill_percent
	
	base_algoritm()
	for i in _smooth_iteration:
		smooth()
	
	return tilemap

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
			fill_percent = 50 # how much walls we want
			
			# fill map with random tiles
			if randi() % 101 < fill_percent or x == 0 or x == size.x - 1 or y == 0 or y == size.y - 1:
				map[i] = 1 # wall
			else:
				map[i] = 0 # empty
	# draw the map
	update_map()
#	get_node("Smooth").set_disabled(false) # when we have a map user can smooth it

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

func debug(message, something1 = "", something2 = ""):
	if debug:
		print("[RPGElements] ", message, " ", something1, " ", something2)
