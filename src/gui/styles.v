module gui

import gx

pub struct ButtonStyle {
pub:
	color              gx.Color = color_1_dark
	color_border       gx.Color = color_border_dark
	color_border_focus gx.Color = color_link_dark
	color_click        gx.Color = color_4_dark
	color_focus        gx.Color = color_2_dark
	color_hover        gx.Color = color_3_dark
	fill               bool     = true
	fill_border        bool     = true
	padding            Padding  = Padding{8, 10, 8, 10}
	padding_border     Padding  = padding_none
	radius             f32      = radius_medium
	radius_border      f32      = radius_medium
}

pub struct ContainerStyle {
pub:
	color   gx.Color = color_transparent
	fill    bool
	padding Padding = padding_medium
	radius  f32     = radius_medium
	spacing f32     = spacing_medium
}

pub struct InputStyle {
pub:
	color              gx.Color  = color_1_dark
	color_border       gx.Color  = color_border_dark
	color_border_focus gx.Color  = color_link_dark
	color_focus        gx.Color  = color_2_dark
	fill               bool      = true
	fill_border        bool      = true
	padding            Padding   = padding_small
	padding_border     Padding   = padding_none
	radius             f32       = radius_medium
	radius_border      f32       = radius_medium
	text_style         TextStyle = text_style_dark
}

pub struct ProgressBarStyle {
pub:
	color     gx.Color = color_1_dark
	color_bar gx.Color = color_5_dark
	fill      bool     = true
	padding   Padding  = padding_medium
	radius    f32      = radius_medium
	size      f32      = size_progress_bar
}

pub struct RectangleStyle {
pub:
	color  gx.Color = color_border_dark
	radius f32      = radius_medium
	fill   bool
}

pub struct TextStyle {
pub:
	color   gx.Color
	size    int
	family  string
	spacing int
}
