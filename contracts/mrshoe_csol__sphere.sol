options {
	width	512
	height	512

	bgcolor 0, 0, .2

	bspdepth 0
	bspleafobjs 16
}

# camera options
camera {
	lookat	 0, 0, 0
	pos	5, 4, 5
	up	0, 1, 0
	fov	45
}

material "red" {
	color 1, 0, 0
	diffuse 1
}
material "green" {
	color 0, 1, 0
	diffuse 1
}
material "blue" {
	color 0, 0, 1
	diffuse .6
	specular .2
}

pointlight
{
    pos 5, 4, 1
    color 1, 1, 1
    wattage 150
}

triangle {
	v1 -10, 0, 10
	v2 10, 0, 10
	v3 10, 0, -10
	n1 0, 1, 0
	n2 0, 1, 0
	n3 0, 1, 0
	material "red"
}
triangle {
	v1 -10, 0, -10
	v2 10, 0, -10
	v3 -10, 0, 10
	n1 0, 1, 0
	n2 0, 1, 0
	n3 0, 1, 0
	material "green"
}
sphere
{
    center 1.5, 1.0,1.5 
    radius 1.0
	material "blue"
}
