module gui

import rand

// Shape is the only data structure in GUI used to draw to the screen.
pub struct Shape {
pub mut:
	id       string // user assigned
	id_focus u32    // >0 indicates shape is focusable. Value determines tabbing order
	type     ShapeType
	uid      u64 = rand.u64() // internal use only
	axis     Axis
	cfg      voidptr
	clip     bool
	color    Color
	disabled bool
	// --- sizes, positions ---
	x          f32
	y          f32
	width      f32
	min_width  f32
	max_width  f32
	height     f32
	min_height f32
	max_height f32
	fill       bool
	h_align    HorizontalAlign
	v_align    VerticalAlign
	padding    Padding
	radius     f32
	sizing     Sizing
	spacing    f32
	// -- text ---
	text              string
	text_lines        []string
	text_style        TextStyle
	text_wrap         bool
	text_line_spacing f32 // additional to normal line spacing
	text_keep_spaces  bool
	text_cursor_x     int = -1
	text_cursor_y     int = -1
	text_sel_beg      u32
	text_sel_end      u32
	// --- scroll ---
	id_scroll_v u32 // >0 indicates shape is scrollable
	scroll_v    f32
	// --- float ---
	float          bool
	float_anchor   FloatAttach
	float_tie_off  FloatAttach
	float_offset_x f32
	float_offset_y f32
	// --- user callbacks ---
	on_char    fn (voidptr, mut Event, &Window) = unsafe { nil }
	on_click   fn (voidptr, mut Event, &Window) = unsafe { nil }
	on_keydown fn (voidptr, mut Event, &Window) = unsafe { nil }
	// --- for internal use and not intended for end users ---
	// --- however, composite views can set these in the   ---
	// --- layout amend callback. See input view on how to ---
	on_char_shape       fn (&Shape, mut Event, &Window) = unsafe { nil }
	on_keydown_shape    fn (&Shape, mut Event, &Window) = unsafe { nil }
	on_mouse_down_shape fn (&Shape, mut Event, &Window) = unsafe { nil }
	on_mouse_move_shape fn (&Shape, mut Event, &Window) = unsafe { nil }
	// mostly for hover and focus highlighting
	amend_layout fn (mut Layout, &Window) = unsafe { nil }
}

// ShapeType defines the kind of Shape.
pub enum ShapeType {
	none
	container
	text
}

// point_in_shape determines if the given point is within the shape's layout
// rectangle Internal use mostly, but useful if designing a new Shape
pub fn (shape Shape) point_in_shape(x f32, y f32) bool {
	return x >= shape.x && x < (shape.x + shape.width) && y >= shape.y
		&& y < (shape.y + shape.height)
}
