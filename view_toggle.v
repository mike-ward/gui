module gui

import gg

// ToggleCfg a.k.a checkbox. [Toggle](#toggle) in its default mode functions and a checkbox.
// However, there is an option of overriding the `text_selected` and `text_unselected` properties.
@[heap]
pub struct ToggleCfg {
pub:
	id                 string
	id_focus           u32
	disabled           bool
	invisible          bool
	text_selected      string = '✓'
	text_unselected    string = ' '
	selected           bool
	fill               bool      = gui_theme.toggle_style.fill
	fill_border        bool      = gui_theme.toggle_style.fill_border
	color              Color     = gui_theme.toggle_style.color
	color_focus        Color     = gui_theme.toggle_style.color_focus
	color_hover        Color     = gui_theme.toggle_style.color_hover
	color_click        Color     = gui_theme.toggle_style.color_click
	color_border       Color     = gui_theme.toggle_style.color_border
	color_border_focus Color     = gui_theme.toggle_style.color_border_focus
	color_selected     Color     = gui_theme.toggle_style.color_selected
	padding            Padding   = gui_theme.toggle_style.padding
	padding_border     Padding   = gui_theme.toggle_style.padding_border
	radius             f32       = gui_theme.toggle_style.radius
	radius_border      f32       = gui_theme.toggle_style.radius_border
	text_style         TextStyle = gui_theme.b4
	on_click           fn (&ToggleCfg, mut Event, mut Window) = unsafe { nil }
}

// toggle creates a toggle button (a.k.a checkbox) from the given [ToggleCfg](#ToggleCfg)
pub fn toggle(cfg ToggleCfg) View {
	color := if cfg.selected { cfg.color_selected } else { cfg.color }
	txt := if cfg.selected { cfg.text_selected } else { cfg.text_unselected }

	return row(
		id:           cfg.id
		id_focus:     cfg.id_focus
		color:        cfg.color_border
		padding:      cfg.padding_border
		fill:         cfg.fill_border
		radius:       cfg.radius_border
		disabled:     cfg.disabled
		invisible:    cfg.invisible
		min_width:    gui_theme.n3.size
		min_height:   gui_theme.n3.size
		cfg:          &cfg
		on_char:      cfg.on_char_button
		on_click:     cfg.on_click
		amend_layout: cfg.amend_layout
		content:      [
			row(
				color:   color
				fill:    cfg.fill
				sizing:  fill_fill
				padding: cfg.padding
				radius:  cfg.radius
				h_align: .center
				v_align: .middle
				content: [
					text(
						text:       txt
						text_style: cfg.text_style
					),
				]
			),
		]
	)
}

fn (cfg &ToggleCfg) on_char_button(_ &ToggleCfg, mut e Event, mut w Window) {
	if e.char_code == ` ` && cfg.on_click != unsafe { nil } {
		cfg.on_click(cfg, mut e, mut w)
		e.is_handled = true
	}
}

fn (cfg &ToggleCfg) amend_layout(mut node Layout, mut w Window) {
	if node.shape.disabled || cfg.on_click == unsafe { nil } {
		return
	}
	if w.is_focus(node.shape.id_focus) {
		node.children[0].shape.color = cfg.color_focus
		node.shape.color = cfg.color_border_focus
	}
	ctx := w.context()
	if node.shape.point_in_shape(f32(ctx.mouse_pos_x), f32(ctx.mouse_pos_y)) {
		if w.dialog_cfg.visible && !node_in_dialog_layout(node) {
			return
		}
		w.set_mouse_cursor_pointing_hand()
		node.children[0].shape.color = cfg.color_hover
		if ctx.mouse_buttons == gg.MouseButtons.left {
			node.children[0].shape.color = cfg.color_click
		}
	}
}
