module gui

// The management of focus and input states poses a problem in stateless views
// because...they're stateless. Instead, the window maintains this state in a
// map where the key is the w.id_focus. This state map is cleared when a new
// view is introduced.
pub struct InputState {
pub mut:
	// positions are number of runes relative to start of input text
	cursor_pos int
	beg_pos    int
	end_pos    int
}
