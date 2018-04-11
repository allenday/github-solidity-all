options {
	# screen dimensions
	width	512
	height	512

	# other options
	bgcolor 0, 0, .2

	bspdepth 3
	bspleafobjs 4
}

# camera options
camera {
	lookat	 0, 0, 0
	pos	5, 5, 5
	up	0, 1, 0
	fov	45
}

material "red" {
	color 1,0,0
	diffuse 1
}
material "blue" {
	color 0,0,1
	diffuse 1
}

pointlight
{
    pos 4, 4, 3
    color 1, 0, 0
    wattage 60
}
pointlight
{
    pos 3, 4, 4
    color 1, 0, 0
    wattage 60
}

triangle {
	v1 0, 0, 0
	v2 10, 0, 0
	v3 10, 0, 10
	n1 0, 1, 0
	n2 0, 1, 0
	n3 0, 1, 0
	material "red"
}
triangle {
	v1 0, 0, 0
	v2 0, 0, 10
	v3 10, 0, 10
	n1 0, 1, 0
	n2 0, 1, 0
	n3 0, 1, 0
	material "red"
}
triangle {
	v1 0, 0, 0
	v2 0, 0, 10
	v3 0, 10, 10
	n1 1, 0, 0
	n2 1, 0, 0
	n3 1, 0, 0
	material "red"
}
triangle {
	v1 0, 0, 0
	v2 0, 10, 0
	v3 0, 10, 10
	n1 1, 0, 0
	n2 1, 0, 0
	n3 1, 0, 0
	material "red"
}
triangle {
	v1 0, 0, 0
	v2 10, 0, 0
	v3 10, 10, 0
	n1 0, 0, 1
	n2 0, 0, 1
	n3 0, 0, 1
	material "red"
}
triangle {
	v1 0, 0, 0
	v2 0, 10, 0
	v3 10, 10, 0
	n1 0, 0, 1
	n2 0, 0, 1
	n3 0, 0, 1
	material "red"
}
sphere
{
    center 1.5, 1.0,1.5 
    radius 1.0
	material "blue"
}
