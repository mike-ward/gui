module gui

pub const version = '0.1.0'

pub enum SizingType {
	dynamic
	fixed
}

pub struct Sizing {
pub:
	across SizingType
	down   SizingType
}

pub struct Padding {
pub mut:
	top    int
	right  int
	bottom int
	left   int
}
