module gui

pub const radius_none = f32(0)
pub const radius_small = f32(3)
pub const radius_medium = f32(5)
pub const radius_large = f32(7)

pub const size_text_tiny = 11
pub const size_text_x_small = 13
pub const size_text_small = 15
pub const size_text_medium = 17
pub const size_text_large = 20
pub const size_text_x_large = 26

pub const spacing_small = 5
pub const spacing_medium = 10
pub const spacing_large = 15
pub const text_line_spacing = f32(0) // additional line height

pub const color_transparent = rgba(0, 0, 0, 0)

const color_0_dark = rgb(48, 48, 48)
const color_1_dark = rgb(64, 64, 64)
const color_2_dark = rgb(74, 74, 74)
const color_3_dark = rgb(84, 84, 84)
const color_4_dark = rgb(94, 94, 94)
const color_5_dark = rgb(104, 104, 104)
const color_border_dark = rgb(100, 100, 100)
const color_link_dark = cornflower_blue
const color_text_dark = rgb(225, 225, 225)

const scroll_multiplier = 20
const scroll_delta_line = 1
const scroll_delta_page = 10
const size_progress_bar = 10

const text_style_dark = TextStyle{
	color:        color_text_dark
	size:         size_text_medium
	line_spacing: text_line_spacing
}

pub struct Theme {
pub:
	name             string = 'default' @[required]
	color_background Color  = color_0_dark
	color_link       Color  = color_link_dark
	color_border     Color  = color_border_dark
	color_0          Color  = color_0_dark
	color_1          Color  = color_1_dark
	color_2          Color  = color_2_dark
	color_3          Color  = color_3_dark
	color_4          Color  = color_4_dark
	color_5          Color  = color_5_dark

	button_style       ButtonStyle
	container_style    ContainerStyle
	input_style        InputStyle
	rectangle_style    RectangleStyle
	progress_bar_style ProgressBarStyle
	text_style         TextStyle
	text_style_bold    TextStyle

	// n's and b's are convienence configs for sizing
	// similar to H1-H6 in html markup. n3 is the
	// same as normal size font used by default in
	// text views
	n1 TextStyle = TextStyle{
		...text_style_dark
		size: size_text_x_large
	}
	n2 TextStyle = TextStyle{
		...text_style_dark
		size: size_text_large
	}
	n3 TextStyle = text_style_dark
	n4 TextStyle = TextStyle{
		...text_style_dark
		size: size_text_small
	}
	n5 TextStyle = TextStyle{
		...text_style_dark
		size: size_text_x_small
	}
	n6 TextStyle = TextStyle{
		...text_style_dark
		size: size_text_tiny
	}
	// Bold
	b1 TextStyle = TextStyle{
		...text_style_dark
		size: size_text_x_large
	}
	b2 TextStyle = TextStyle{
		...text_style_dark
		size: size_text_large
	}
	b3 TextStyle = TextStyle{
		...text_style_dark
		size: size_text_medium
	}
	b4 TextStyle = TextStyle{
		...text_style_dark
		size: size_text_small
	}
	b5 TextStyle = TextStyle{
		...text_style_dark
		size: size_text_x_small
	}
	b6 TextStyle = TextStyle{
		...text_style_dark
		size: size_text_tiny
	}
	// italic
	i1 TextStyle = TextStyle{
		...text_style_dark
		size: size_text_x_large
	}
	i2 TextStyle = TextStyle{
		...text_style_dark
		size: size_text_large
	}
	i3 TextStyle = TextStyle{
		...text_style_dark
		size: size_text_medium
	}
	i4 TextStyle = TextStyle{
		...text_style_dark
		size: size_text_small
	}
	i5 TextStyle = TextStyle{
		...text_style_dark
		size: size_text_x_small
	}
	i6 TextStyle = TextStyle{
		...text_style_dark
		size: size_text_tiny
	}
	// Mono
	m1 TextStyle = TextStyle{
		...text_style_dark
		size: size_text_x_large
	}
	m2 TextStyle = TextStyle{
		...text_style_dark
		size: size_text_large
	}
	m3 TextStyle = TextStyle{
		...text_style_dark
		size: size_text_medium
	}
	m4 TextStyle = TextStyle{
		...text_style_dark
		size: size_text_small
	}
	m5 TextStyle = TextStyle{
		...text_style_dark
		size: size_text_x_small
	}
	m6 TextStyle = TextStyle{
		...text_style_dark
		size: size_text_tiny
	}

	padding_small  Padding = padding_small
	padding_medium Padding = padding_medium
	padding_large  Padding = padding_large

	spacing_small  int = spacing_small
	spacing_medium int = spacing_medium
	spacing_large  int = spacing_large
	spacing_text   f32 = text_line_spacing // additional line height

	size_text_tiny    int = size_text_tiny
	size_text_x_small int = size_text_x_small
	size_text_small   int = size_text_small
	size_text_medium  int = size_text_medium
	size_text_large   int = size_text_large
	size_text_x_large int = size_text_x_large

	scroll_multiplier f32 = scroll_multiplier
	scroll_delta_line f32 = scroll_delta_line
	scroll_delta_page f32 = scroll_delta_page
}

pub struct ThemeCfg {
pub:
	name               string @[required]
	color_0            Color     = color_0_dark
	color_1            Color     = color_1_dark
	color_2            Color     = color_2_dark
	color_3            Color     = color_3_dark
	color_4            Color     = color_4_dark
	color_5            Color     = color_5_dark
	color_border       Color     = color_border_dark
	color_border_focus Color     = color_link_dark
	color_link         Color     = color_link_dark
	color_text         Color     = color_text_dark
	fill               bool      = true
	fill_border        bool      = true
	padding            Padding   = padding_medium
	padding_border     Padding   = padding_none
	radius             f32       = radius_medium
	radius_border      f32       = radius_medium + 2
	text_style         TextStyle = text_style_dark

	// Usually don't change across styles
	padding_small  Padding = padding_small
	padding_medium Padding = padding_medium
	padding_large  Padding = padding_large

	spacing_small  int = spacing_small
	spacing_medium int = spacing_medium
	spacing_large  int = spacing_large
	spacing_text   f32 = text_line_spacing // additional line height

	size_text_tiny    int = size_text_tiny
	size_text_x_small int = size_text_x_small
	size_text_small   int = size_text_small
	size_text_medium  int = size_text_medium
	size_text_large   int = size_text_large
	size_text_x_large int = size_text_x_large

	scroll_multiplier f32 = scroll_multiplier
	scroll_delta_line f32 = scroll_delta_line
	scroll_delta_page f32 = scroll_delta_page
}

pub const theme_dark = theme_maker(
	name:               'dark'
	color_0:            color_0_dark
	color_1:            color_1_dark
	color_2:            color_2_dark
	color_3:            color_3_dark
	color_4:            color_4_dark
	color_5:            color_5_dark
	color_border:       color_border_dark
	color_border_focus: color_link_dark
	color_link:         color_link_dark
	text_style:         text_style_dark
)

pub const theme_dark_no_padding = theme_maker(
	name:               'dark'
	color_0:            color_0_dark
	color_1:            color_1_dark
	color_2:            color_2_dark
	color_3:            color_3_dark
	color_4:            color_4_dark
	color_5:            color_5_dark
	color_border:       color_border_dark
	color_border_focus: color_link_dark
	color_link:         color_link_dark
	text_style:         text_style_dark
	padding:            padding_none
	padding_border:     padding_none
	radius:             radius_none
	radius_border:      radius_none
)

const color_text_light = rgb(32, 32, 32)
const color_0_light = rgb(225, 225, 225)
const color_1_light = rgb(150, 150, 255)
const color_2_light = rgb(140, 140, 255)
const color_3_light = rgb(130, 130, 255)
const color_4_light = rgb(120, 120, 255)
const color_5_light = rgb(91, 91, 255)
const color_border_light = rgb(64, 64, 64)
const color_link_light = rgb(0, 71, 171)
const color_border_focus_light = rgb(0, 0, 255)

pub const theme_light = theme_maker(
	name:               'light'
	color_0:            color_0_light
	color_1:            color_1_light
	color_2:            color_2_light
	color_3:            color_3_light
	color_4:            color_4_light
	color_5:            color_5_light
	color_border:       color_border_light
	color_link:         color_link_light
	color_border_focus: color_border_focus_light
	text_style:         TextStyle{
		...text_style_dark
		color: color_text_light
	}
)

pub const theme_light_no_padding = theme_maker(
	name:               'light'
	color_0:            color_0_light
	color_1:            color_1_light
	color_2:            color_2_light
	color_3:            color_3_light
	color_4:            color_4_light
	color_5:            color_5_light
	color_border:       color_border_light
	color_link:         color_link_light
	color_border_focus: color_border_focus_light
	text_style:         TextStyle{
		...text_style_dark
		color: color_text_light
	}
	padding:            padding_none
	padding_border:     padding_none
	radius:             radius_none
	radius_border:      radius_none
)

// theme_maker sets all styles to a common set of values (ThemeCfg)
// GUI allows each view type (button, input, etc) to be styled
// independent of the other view styles. However, in practice this
// is not usually required. theme_maker makes it easy to write
// new themes without having to specify styles for every view type.
// Individual styles can be modified after using theme_maker.
// Note: `theme_maker` containers are always transparent and not
// filled.
pub fn theme_maker(cfg ThemeCfg) Theme {
	theme := Theme{
		name:             cfg.name
		color_background: cfg.color_0
		color_link:       cfg.color_link
		color_border:     cfg.color_border
		color_0:          cfg.color_0
		color_1:          cfg.color_1
		color_2:          cfg.color_2
		color_3:          cfg.color_3
		color_4:          cfg.color_4
		color_5:          cfg.color_5

		button_style:       ButtonStyle{
			color:              cfg.color_1
			color_border:       cfg.color_border
			color_border_focus: cfg.color_border_focus
			color_click:        cfg.color_4
			color_focus:        cfg.color_2
			color_hover:        cfg.color_3
			fill:               cfg.fill
			fill_border:        cfg.fill_border
			padding:            cfg.padding
			padding_border:     cfg.padding_border
			radius:             cfg.radius
			radius_border:      cfg.radius_border
		}
		container_style:    ContainerStyle{
			color:   color_transparent
			fill:    false
			padding: cfg.padding
			radius:  cfg.radius
			spacing: cfg.spacing_medium
		}
		input_style:        InputStyle{
			color:              cfg.color_1
			color_border:       cfg.color_border
			color_border_focus: cfg.color_border_focus
			color_focus:        cfg.color_2
			fill:               cfg.fill
			fill_border:        cfg.fill_border
			padding:            cfg.padding
			padding_border:     cfg.padding_border
			radius:             cfg.radius
			radius_border:      cfg.radius_border
			text_style:         cfg.text_style
		}
		progress_bar_style: ProgressBarStyle{
			color:     cfg.color_1
			color_bar: cfg.color_5
			fill:      true
			radius:    cfg.radius
		}
		rectangle_style:    RectangleStyle{
			color:  cfg.color_border
			radius: cfg.radius
			fill:   cfg.fill
		}
		text_style:         cfg.text_style

		// Usually don't change
		padding_small:  cfg.padding_small
		padding_medium: cfg.padding_medium
		padding_large:  cfg.padding_large

		spacing_small:  cfg.spacing_small
		spacing_medium: cfg.spacing_medium
		spacing_large:  cfg.spacing_large
		spacing_text:   cfg.spacing_text

		size_text_tiny:    cfg.size_text_tiny
		size_text_x_small: cfg.size_text_x_small
		size_text_small:   cfg.size_text_small
		size_text_medium:  cfg.size_text_medium
		size_text_large:   cfg.size_text_large
		size_text_x_large: cfg.size_text_x_large

		scroll_multiplier: cfg.scroll_multiplier
		scroll_delta_line: cfg.scroll_delta_line
		scroll_delta_page: cfg.scroll_delta_page
	}

	variants := font_variants(theme.text_style)
	normal := TextStyle{
		...theme.text_style
		family: variants.normal
	}
	bold := TextStyle{
		...theme.text_style
		family: variants.bold
	}
	italic := TextStyle{
		...theme.text_style
		family: variants.italic
	}
	mono := TextStyle{
		...theme.text_style
		family: variants.mono
	}

	return Theme{
		...theme
		n1: TextStyle{
			...normal
			size: theme.size_text_x_large
		}
		n2: TextStyle{
			...normal
			size: theme.size_text_large
		}
		n3: theme.text_style
		n4: TextStyle{
			...normal
			size: theme.size_text_small
		}
		n5: TextStyle{
			...normal
			size: theme.size_text_x_small
		}
		n6: TextStyle{
			...normal
			size: theme.size_text_tiny
		}
		// Bold
		b1: TextStyle{
			...bold
			size: theme.size_text_x_large
		}
		b2: TextStyle{
			...bold
			size: theme.size_text_large
		}
		b3: TextStyle{
			...bold
			size: theme.size_text_medium
		}
		b4: TextStyle{
			...bold
			size: theme.size_text_small
		}
		b5: TextStyle{
			...bold
			size: theme.size_text_x_small
		}
		b6: TextStyle{
			...bold
			size: theme.size_text_tiny
		}
		// Italic
		i1: TextStyle{
			...italic
			size: theme.size_text_x_large
		}
		i2: TextStyle{
			...italic
			size: theme.size_text_large
		}
		i3: TextStyle{
			...italic
			size: theme.size_text_medium
		}
		i4: TextStyle{
			...italic
			size: theme.size_text_small
		}
		i5: TextStyle{
			...italic
			size: theme.size_text_x_small
		}
		i6: TextStyle{
			...italic
			size: theme.size_text_tiny
		}
		// Mono
		m1: TextStyle{
			...mono
			size: theme.size_text_x_large
		}
		m2: TextStyle{
			...mono
			size: theme.size_text_large
		}
		m3: TextStyle{
			...mono
			size: theme.size_text_medium
		}
		m4: TextStyle{
			...mono
			size: theme.size_text_small
		}
		m5: TextStyle{
			...mono
			size: theme.size_text_x_small
		}
		m6: TextStyle{
			...mono
			size: theme.size_text_tiny
		}
	}
}

// theme returns the current theme.
pub fn theme() Theme {
	return gui_theme
}
