module gui

import gg
import gx

// Shape is the only data structure in GUI used to draw to the screen.
pub struct Shape {
pub:
	id        string // asigned by user
	uid       string
	type      ShapeType
	direction ShapeDirection
mut:
	x          f32
	y          f32
	width      f32
	height     f32
	spacing    f32
	sizing     Sizing
	padding    Padding
	fill       bool
	radius     int
	color      gg.Color
	text       string
	lines      []string
	text_cfg   gx.TextCfg
	wrap       bool
	min_width  f32
	min_height f32
	bounds     gg.Rect
	on_click   fn (string, MouseEvent, &Window) = unsafe { nil }
}

// ShapeType defines the kind of Shape.
pub enum ShapeType {
	none
	container
	rectangle
	text
	line
	image
}

// ShapeDirection defines if a Shape arranges its child
// shapes horizontally, vertically or not at all.
pub enum ShapeDirection {
	none
	top_to_bottom
	left_to_right
}

// ShapeTree defines a tree of Shapes. UI_Trees generate ShapeTrees
pub struct ShapeTree {
pub mut:
	shape    Shape
	children []ShapeTree
}

const empty_shape_id = '__empty_shape__'
const empty_shape = Shape{
	id: empty_shape_id
}
const empty_shape_tree = ShapeTree{
	shape: empty_shape
}

fn (node ShapeTree) clone() ShapeTree {
	mut clone := ShapeTree{
		shape: Shape{
			...node.shape
		}
	}
	for child in node.children {
		clone.children << child.clone()
	}
	return clone
}

// draw
// Drawing a shape it just that. No decisions about UI state are considered.
// If the UI state of your view changes, Generate an new view and update the window
// with the new view. New shapes are generated based on the view (UI_Tree).
// Data flows one way from view -> shapes or in terms of data structures
// from UI_Tree -> ShapeTree
pub fn (shape Shape) draw(ctx gg.Context) {
	match shape.type {
		.container { shape.draw_rectangle(ctx) }
		.rectangle { shape.draw_rectangle(ctx) }
		.text { shape.draw_text(ctx) }
		.image {}
		.line {}
		.none {}
	}
}

// draw_rectangle draws a shape as a rectangle.
pub fn (shape Shape) draw_rectangle(ctx gg.Context) {
	assert shape.type in [.container, .rectangle]
	shape.shape_clip(ctx)
	defer { shape.shape_unclip(ctx) }

	ctx.draw_rect(
		x:          shape.x
		y:          shape.y
		w:          shape.width
		h:          shape.height
		color:      shape.color
		style:      if shape.fill { .fill } else { .stroke }
		is_rounded: shape.radius > 0
		radius:     shape.radius
	)
}

// draw_text draws a shape as text
pub fn (shape Shape) draw_text(ctx gg.Context) {
	assert shape.type == .text
	shape.shape_clip(ctx)
	defer { shape.shape_unclip(ctx) }

	lh := line_height(shape, ctx)
	mut y := int(shape.y + f32(0.49999))
	for line in shape.lines {
		ctx.draw_text(int(shape.x), y, line, shape.text_cfg)
		y += lh
	}
}

// is_empty_rect returns true if the rectangle has no area, positive
// or negative.
pub fn is_empty_rect(rect gg.Rect) bool {
	return (rect.x + rect.width) == 0 && (rect.y + rect.height) == 0
}

// shape_clip sets up a clipping region based on the shapes's bounds property.'
pub fn (shape Shape) shape_clip(ctx gg.Context) {
	if !is_empty_rect(shape.bounds) {
		x := int(shape.bounds.x - 1)
		y := int(shape.bounds.y - 1)
		w := int(shape.bounds.width + 1)
		h := int(shape.bounds.height + 1)
		ctx.scissor_rect(x, y, w, h)
	}
}

// shape_unclip resets the clipping region.
pub fn (shape Shape) shape_unclip(ctx gg.Context) {
	ctx.scissor_rect(0, 0, max_int, max_int)
}

// point_in_shape determines if the given point is within the shape's layout rectangle
pub fn (shape Shape) point_in_shape(x f32, y f32) bool {
	return x >= shape.x && x < (shape.x + shape.width) && y >= shape.y
		&& y < (shape.y + shape.height)
}

// shape_from_point_on_click walks the ShapeTree and returns the first
// shape where the sahpe region contains the point and the shape has
// a click handler. Search is in reverse order
pub fn shape_from_point_on_click(node ShapeTree, x f32, y f32) Shape {
	mut shape := empty_shape
	for child in node.children {
		shape = shape_from_point_on_click(child, x, y)
		if shape.id != empty_shape_id {
			return shape
		}
	}
	if node.shape.point_in_shape(x, y) && node.shape.on_click != unsafe { nil } {
		return node.shape
	}
	return shape
}
