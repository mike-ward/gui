module gui

import gg

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
		shape.max_height = shape.lines.len * lh
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
// strings. Newlines are separated from other white-space.
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
