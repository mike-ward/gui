module gui

import gg
import gx

struct DrawTextCfg {
pub:
	x    f32
	y    f32
	text string
	cfg  gx.TextCfg
}

struct DrawLineCfg {
	x   f32
	y   f32
	x1  f32
	y1  f32
	cfg gx.Color
}

struct DrawNoneCfg {}

// A Renderer is the final computed drawing command. The window keeps
// an array of Renderer and only uses this array to paint the window.
// The window can be rapainted many times before the view state changes.
// Storing the final draw commands vs. calling render_shape() is faster
// because there is no computation to build the draw command.
type DrawRect = gg.DrawRectParams
type DrawText = DrawTextCfg
type DrawClip = gg.Rect
type DrawLine = DrawLineCfg
type DrawNone = DrawNoneCfg
type Renderer = DrawRect | DrawText | DrawClip | DrawLine | DrawNone

fn render_draw(draw Renderer, ctx &gg.Context) {
	match draw {
		DrawRect { ctx.draw_rect(draw) }
		DrawText { ctx.draw_text(int(draw.x), int(draw.y), draw.text, draw.cfg) }
		DrawClip { ctx.scissor_rect(int(draw.x), int(draw.y), int(draw.width), int(draw.height)) }
		DrawLine { ctx.draw_line(draw.x, draw.y, draw.x1, draw.y1, draw.cfg) }
		DrawNone {}
	}
}

fn render(shapes ShapeTree, ctx &gg.Context) []Renderer {
	mut renderers := []Renderer{}
	renderers << render_shape(shapes.shape, ctx)
	for child in shapes.children {
		renderers << render(child, ctx)
	}
	return renderers
}

fn render_shape(shape Shape, ctx &gg.Context) []Renderer {
	return match shape.type {
		.container { render_rectangle(shape, ctx) }
		.text { render_text(shape, ctx) }
		.none { [Renderer(DrawNone{})] }
	}
}

// draw_rectangle draws a shape as a rectangle.
fn render_rectangle(shape Shape, ctx &gg.Context) []Renderer {
	assert shape.type == .container
	mut renderers := []Renderer{}
	renderers << shape_clip(shape, ctx)
	renderers << DrawRect{
		x:          shape.x
		y:          shape.y
		w:          shape.width
		h:          shape.height
		color:      shape.color
		style:      if shape.fill { .fill } else { .stroke }
		is_rounded: shape.radius > 0
		radius:     shape.radius
	}
	renderers << shape_unclip(ctx)
	return renderers
}

fn render_text(shape Shape, ctx &gg.Context) []Renderer {
	assert shape.type == .text
	mut renderers := []Renderer{}
	renderers << shape_clip(shape, ctx)

	lh := line_height(shape, ctx)
	mut y := int(shape.y + f32(0.49999))
	for line in shape.lines {
		renderers << DrawText{
			x:    shape.x
			y:    y
			text: line
			cfg:  shape.text_cfg
		}
		y += lh
	}

	if shape.cursor_x >= 0 && shape.cursor_y >= 0 {
		if shape.cursor_y < shape.lines.len {
			ln := shape.lines[shape.cursor_y]
			if shape.cursor_x <= ln.len {
				cx := shape.x + ctx.text_width(ln[..shape.cursor_x])
				cy := shape.y + (lh * shape.cursor_y)
				renderers << DrawLine{
					x:   cx
					y:   cy
					x1:  cx
					y1:  cy + lh
					cfg: shape.text_cfg.color
				}
			}
		}
	}
	renderers << shape_unclip(ctx)
	return renderers
}

// shape_clip creates a clipping region based on the shapes's bounds property.
// Internal use mostly, but useful if designing a new Shape
pub fn shape_clip(shape Shape, ctx &gg.Context) Renderer {
	if !is_empty_rect(shape.bounds) {
		x := int(shape.bounds.x - 1)
		y := int(shape.bounds.y - 1)
		w := int(shape.bounds.width + 1)
		h := int(shape.bounds.height + 1)
		return DrawClip{
			x:      x
			y:      y
			width:  w
			height: h
		}
	}
	return DrawNone{}
}

// shape_unclip resets the clipping region.
// Internal use mostly, but useful if designing a new Shape
pub fn shape_unclip(ctx &gg.Context) DrawClip {
	return DrawClip{
		x:      0
		y:      0
		width:  max_int
		height: max_int
	}
}

// is_empty_rect returns true if the rectangle has no area, positive
// or negative.
pub fn is_empty_rect(rect gg.Rect) bool {
	return (rect.x + rect.width) == 0 && (rect.y + rect.height) == 0
}
