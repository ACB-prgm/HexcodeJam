extends Node


var enemy_1 = preload("res://Scenes/Enemies/Enemy_1.tscn")
var enemy_2 = preload("res://Scenes/Enemies/Enemy_2.tscn")
var enemy_3 = preload("res://Scenes/Enemies/Enemy_3.tscn")

var enemies = {
	1: enemy_1,
	2: enemy_2,
	3: enemy_3
}

var Nights = {
	1: {
		1 : 0,
		2 : 0,
		3 : 3,
	},
	2: {
		1 : 0,
		2 : 3,
		3 : 1,
	},
	3: {
		1 : 1,
		2 : 1,
		3 : 3,
	},
	4: {
		1 : 2,
		2 : 3,
		3 : 3,
	},
	5: {
		1 : 2,
		2 : 4,
		3 : 5,
	}
}
