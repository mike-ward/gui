module gui

import gx

pub struct Rectangle implements UI_Tree {
pub:
	x      int
	y      int
	width  int
	height int
	filled bool
	radius int
	color  gx.Color
pub mut:
	children []UI_Tree
}

pub fn (rectangle &Rectangle) generate() []Shape {
	return [
		Shape{
			type:      .rectangle
			direction: .none
			x:         rectangle.x
			y:         rectangle.y
			width:     rectangle.width
			height:    rectangle.height
			filled:    rectangle.filled
			radius:    rectangle.radius
			color:     rectangle.color
		},
	]
}
