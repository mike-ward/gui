module gui

import gg
import gx

// Text is an internal structure used to describe a text block
@[heap]
struct Text implements View {
	id       string
	id_focus u32 // >0 indicates text is focusable. Value indiciates tabbing order
mut:
	min_width   f32
	max_width   f32
	spacing     f32
	text_cfg    gx.TextCfg
	text        string
	wrap        bool
	keep_spaces bool
	sizing      Sizing
	disabled    bool
	clip        bool
	cfg         TextCfg
	v_scroll_id u32
	content     []View
}

fn (t Text) generate(ctx gg.Context) Layout {
	mut shape_tree := Layout{
		shape: Shape{
			id:          t.id
			id_focus:    t.id_focus
			type:        .text
			spacing:     t.spacing
			text:        t.text
			text_cfg:    t.text_cfg
			lines:       [t.text]
			wrap:        t.wrap
			keep_spaces: t.keep_spaces
			sizing:      t.sizing
			disabled:    t.disabled
			min_width:   t.min_width
			v_scroll_id: t.v_scroll_id
			clip:        t.clip || t.v_scroll_id > 0
		}
	}
	shape_tree.shape.width = text_width(shape_tree.shape, ctx)
	shape_tree.shape.height = text_height(shape_tree.shape, ctx)
	if !t.wrap || shape_tree.shape.sizing.width == .fixed {
		shape_tree.shape.min_width = f32_max(shape_tree.shape.width, shape_tree.shape.min_width)
		shape_tree.shape.width = shape_tree.shape.min_width
	}
	if !t.wrap || shape_tree.shape.sizing.height == .fixed {
		shape_tree.shape.min_height = f32_max(shape_tree.shape.height, shape_tree.shape.min_height)
		shape_tree.shape.height = shape_tree.shape.height
	}
	return shape_tree
}

pub struct TextCfg {
pub:
	id          string
	id_focus    u32
	min_width   f32
	spacing     f32        = gui_theme.text_style.spacing
	text_cfg    gx.TextCfg = gui_theme.text_style.text_cfg
	text        string
	wrap        bool
	keep_spaces bool
	disabled    bool
	clip        bool
	v_scroll_id u32
}

// text renders text. Text wrapping is available. Multiple spaces are compressed
// to one space unless `keep_spaces` is true. The `spacing` parameter is used to
// increase the space between lines.
pub fn text(cfg TextCfg) Text {
	return Text{
		id:          cfg.id
		id_focus:    cfg.id_focus
		min_width:   cfg.min_width
		spacing:     cfg.spacing
		text_cfg:    cfg.text_cfg
		text:        cfg.text
		wrap:        cfg.wrap
		cfg:         &cfg
		keep_spaces: cfg.keep_spaces
		sizing:      if cfg.wrap { fill_fit } else { fit_fit }
		disabled:    cfg.disabled
		v_scroll_id: cfg.v_scroll_id
	}
}

fn text_width(shape Shape, ctx gg.Context) int {
	ctx.set_text_cfg(shape.text_cfg)
	mut max_width := 0
	for line in shape.lines {
		width := ctx.text_width(line)
		max_width = int_max(width, max_width)
	}
	return max_width
}

fn text_height(shape Shape, ctx gg.Context) int {
	assert shape.type == .text
	lh := line_height(shape, ctx)
	return lh * shape.lines.len
}

fn line_height(shape Shape, ctx gg.Context) int {
	assert shape.type == .text
	ctx.set_text_cfg(shape.text_cfg)
	return ctx.text_height('Q|W') + int(shape.spacing + f32(0.4999)) + 2
}

fn text_wrap(mut shape Shape, ctx gg.Context) {
	if shape.type == .text && shape.wrap {
		ctx.set_text_cfg(shape.text_cfg)
		shape.lines = match shape.keep_spaces {
			true { text_wrap_text_keep_spaces(shape.text, shape.width, ctx) }
			else { text_wrap_text(shape.text, shape.width, ctx) }
		}

		shape.width = text_width(shape, ctx)
		lh := line_height(shape, ctx)
		shape.height = shape.lines.len * lh
		shape.min_height = shape.height
	}
}

// text_wrap_text wraps lines to given width (logical units, not chars)
// Extra white space is compressed to on space including tabs and newlines.
fn text_wrap_text(s string, width f32, ctx gg.Context) []string {
	mut line := ''
	mut wrap := []string{cap: 5}
	for field in s.fields() {
		if line.len == 0 {
			line = field
			continue
		}
		nline := line + ' ' + field
		t_width := ctx.text_width(nline)
		if t_width > width {
			wrap << line
			line = field.trim_space()
		} else {
			line = nline
		}
	}
	wrap << line
	return wrap
}

// text_wrap_text_keep_spaces wraps lines to given width (logical units, not
// chars) White space is preserved except leading spaces at the start of a
// wrapped line.
fn text_wrap_text_keep_spaces(s string, width f32, ctx gg.Context) []string {
	mut line := ''
	mut wrap := []string{cap: 5}
	for field in split_text(s) {
		if field == '\n' {
			wrap << line
			line = ''
			continue
		}
		if line.len == 0 {
			line = field.trim_space()
			continue
		}
		nline := line + field
		t_width := ctx.text_width(nline)
		if t_width > width {
			wrap << line
			line = field.trim_space()
		} else {
			line = nline
		}
	}
	wrap << line
	return wrap
}

// split_text splits a string by spaces and also includes the spaces as separate
// strings
fn split_text(s string) []string {
	space := ' '
	state_un := 0
	state_sp := 1
	state_ch := 2

	mut state := state_un
	mut fields := []string{}
	mut field := ''

	for r in s.runes() {
		ch := r.str()
		if state == state_un {
			field += ch
			state = if ch == space { state_sp } else { state_ch }
		} else if state == state_sp {
			if ch == space {
				field += ch
			} else {
				state = state_ch
				fields << field
				field = ch
			}
		} else if state == state_ch {
			if ch == space {
				state = state_sp
				fields << field
				field = ch
			} else if ch == '\n' {
				fields << field
				fields << '\n'
				field = ''
			} else if ch.is_blank() {
				// eat it
			} else {
				field += ch
			}
		}
	}
	fields << field
	return fields
}
