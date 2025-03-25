module gui

import gg
import gx

struct Container implements View {
pub mut:
	id           string
	id_focus     FocusId
	axis         Axis
	x            f32
	y            f32
	width        f32
	min_width    f32
	height       f32
	min_height   f32
	clip         bool
	spacing      f32
	sizing       Sizing
	padding      Padding
	fill         bool
	h_align      HorizontalAlign
	v_align      VerticalAlign
	radius       int
	color        gx.Color
	cfg          voidptr
	on_char      fn (u32, &Window)                          = unsafe { nil }
	on_click     fn (voidptr, MouseEvent, &Window)          = unsafe { nil }
	on_keydown   fn (gg.KeyCode, gg.Modifier, &Window) bool = unsafe { nil }
	on_mouseover fn (f32, f32, &Window)                     = unsafe { nil }
	amend_layout fn (mut ShapeTree, &Window)                = unsafe { nil }
	children     []View
}

fn (cfg &Container) generate(_ gg.Context) ShapeTree {
	return ShapeTree{
		shape: Shape{
			id:           cfg.id
			id_focus:     cfg.id_focus
			type:         .container
			axis:         cfg.axis
			x:            cfg.x
			y:            cfg.y
			width:        cfg.width
			height:       cfg.height
			clip:         cfg.clip
			spacing:      cfg.spacing
			sizing:       cfg.sizing
			padding:      cfg.padding
			fill:         cfg.fill
			h_align:      cfg.h_align
			v_align:      cfg.v_align
			radius:       cfg.radius
			color:        cfg.color
			min_width:    cfg.min_width
			min_height:   cfg.min_height
			cfg:          cfg.cfg
			on_click:     cfg.on_click
			on_char:      cfg.on_char
			on_keydown:   cfg.on_keydown
			amend_layout: cfg.amend_layout
		}
	}
}

// ContainerCfg is the common configuration struct for row, column and canvas containers
pub struct ContainerCfg {
pub:
	id           string
	id_focus     int
	x            f32
	y            f32
	width        f32
	min_width    f32
	height       f32
	min_height   f32
	clip         bool
	sizing       Sizing
	fill         bool
	h_align      HorizontalAlign
	v_align      VerticalAlign
	cfg          voidptr
	spacing      f32                                        = spacing_default
	radius       int                                        = radius_default
	color        gx.Color                                   = transparent
	padding      Padding                                    = padding_default
	on_char      fn (u32, &Window)                          = unsafe { nil }
	on_click     fn (voidptr, MouseEvent, &Window)          = unsafe { nil }
	on_keydown   fn (gg.KeyCode, gg.Modifier, &Window) bool = unsafe { nil }
	on_mouseover fn (f32, f32, &Window)                     = unsafe { nil }
	amend_layout fn (mut ShapeTree, &Window)                = unsafe { nil }
	children     []View
}

// container is the fundamental layout container in gui. It is used to layout
// its children top-to-bottom or left_to_right. A `.none` axis allows a
// container to behave as a canvas with no additional layout.
fn container(cfg ContainerCfg) &Container {
	return &Container{
		id:           cfg.id
		id_focus:     cfg.id_focus
		x:            cfg.x
		y:            cfg.y
		width:        cfg.width
		min_width:    cfg.min_width
		height:       cfg.height
		min_height:   cfg.min_height
		clip:         cfg.clip
		color:        cfg.color
		fill:         cfg.fill
		h_align:      cfg.h_align
		v_align:      cfg.v_align
		padding:      cfg.padding
		radius:       cfg.radius
		sizing:       cfg.sizing
		spacing:      cfg.spacing
		cfg:          cfg.cfg
		on_click:     cfg.on_click
		on_char:      cfg.on_char
		on_keydown:   cfg.on_keydown
		on_mouseover: cfg.on_mouseover
		amend_layout: cfg.amend_layout
		children:     cfg.children
	}
}

// --- Common layout containers ---

// column arranges its children top to bottom. The gap between child items is
// determined by the spacing parameter.
pub fn column(cfg ContainerCfg) &Container {
	mut col := container(cfg)
	col.axis = .top_to_bottom
	return col
}

// row arranges its children left to right. The gap between child items is
// determined by the spacing parameter.
pub fn row(cfg ContainerCfg) &Container {
	mut row := container(cfg)
	row.axis = .left_to_right
	return row
}

// canvas does not arrange or otherwise layout its children.
pub fn canvas(cfg ContainerCfg) &Container {
	return container(cfg)
}
