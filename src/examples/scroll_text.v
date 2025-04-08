import gui
import gg

struct App {
pub mut:
	light bool
	text  string = '
Far far away, behind the word mountains, far from the countries Vokalia and Consonantia, there live the blind texts.

Separated they live in Bookmarksgrove right at the coast of the Semantics, a large language ocean.

A small river named Duden flows by their place and supplies it with the necessary regelialia.

It is a paradisematic country, in which roasted parts of sentences fly into your mouth.

Even the all-powerful Pointing has no control about the blind texts it is an almost unorthographic life. One day however a small line of blind text by the name of Lorem Ipsum decided to leave for the far World of Grammar.

The Big Oxmox advised her not to do so, because there were thousands of bad Commas, wild Question Marks and devious Semikoli, but the Little Blind Text didn’t listen.

She packed her seven versalia, put her initial into the belt and made herself on the way.

When she reached the first hills of the Italic Mountains, she had a last view back on the skyline of her hometown Bookmarksgrove, the headline of Alphabet Village and the subline of her own road, the Line Lane.

Pityful a rethoric question ran over her cheek, then'
}

fn main() {
	mut window := gui.window(
		state:   &App{}
		width:   400
		height:  600
		on_init: fn (mut w gui.Window) {
			w.update_view(main_view)
		}
	)
	window.run()
}

fn main_view(window &gui.Window) gui.View {
	w, h := window.window_size()
	app := window.state[App]()

	return gui.column(
		width:   w
		height:  h
		sizing:  gui.fixed_fixed
		content: [
			button_change_theme(app),
			gui.rectangle(height: 0.5, sizing: gui.fill_fixed),
			gui.row(
				padding: gui.padding_none
				sizing:  gui.fill_fill
				content: [
					gui.column(
						id_scroll_v: 1
						padding:     gui.padding_small
						sizing:      gui.fill_fill
						content:     [
							gui.text(
								text:        app.text
								keep_spaces: true
								wrap:        true
							),
						]
					),
					gui.column(
						id_scroll_v: 2
						padding:     gui.padding_small
						sizing:      gui.fill_fill
						content:     [
							gui.text(
								text:        app.text
								keep_spaces: true
								wrap:        true
							),
						]
					),
				]
			),
		]
	)
}

fn button_change_theme(app &App) gui.View {
	return gui.row(
		h_align: .right
		sizing:  gui.fill_fit
		padding: gui.padding_none
		content: [
			gui.button(
				padding:  gui.padding(1, 5, 1, 5)
				content:  [
					gui.text(
						text: if app.light { '●' } else { '○' }
					),
				]
				on_click: fn (_ &gui.ButtonCfg, _ &gg.Event, mut w gui.Window) bool {
					mut app := w.state[App]()
					app.light = !app.light
					theme := if app.light {
						gui.theme_light
					} else {
						gui.theme_dark
					}
					w.set_theme(theme)
					w.set_id_focus(1)
					return true
				}
			),
		]
	)
}
