options {
	width	1024
	height	768

	bgcolor 0, 0, .2

	bspdepth 1
	bspleafobjs 20
}

# camera options
camera {
	lookat	 0, 5, 0
	pos	0, 5, 16
	up	0, 1, 0
	fov	45
}

pointlight
{
	pos 0, 8,0 
	color 1, 1, 1
	wattage 200
}

material "white" {
	color 1, 1, 1
	diffuse 1
}
material "red" {
	color 1, .45, .45
	diffuse 1
}
material "blue" {
	color .45, .65, 1
	diffuse 1
}
material "green" {
	color .15, 1, .15
	diffuse 1
}
material "mirror" {
	color 0, 0, 0
	specular .7
}
material "rglass" {
	color .9, 0, 0
	diffuse 1
}
#floor
triangle {
	v1 -5, 0, 5
	v2 5, 0, 5
	v3 5, 0, -5
	n1 0, 1, 0
	n2 0, 1, 0
	n3 0, 1, 0
	material "white"
}
triangle {
	v1 -5, 0, -5
	v2 5, 0, -5
	v3 -5, 0, 5
	n1 0, 1, 0
	n2 0, 1, 0
	n3 0, 1, 0
	material "white"
}
#ceiling
triangle {
	v1 -5, 10, 5
	v2 5, 10, 5
	v3 5, 10, -5
	n1 0, -1, 0
	n2 0, -1, 0
	n3 0, -1, 0
	material "white"
}
triangle {
	v1 -5,10, -5
	v2 5, 10, -5
	v3 -5, 10, 5
	n1 0, -1, 0
	n2 0, -1, 0
	n3 0, -1, 0
	material "white"
}
#back wall
triangle {
	v1 -5, 0, -5
	v2 5, 0, -5
	v3 5, 10, -5
	n1 0, 0, 1
	n2 0, 0, 1
	n3 0, 0, 1
	material "white"
}
triangle {
	v1 -5, 0, -5
	v2 5, 10, -5
	v3 -5, 10, -5
	n1 0, 0, 1
	n2 0, 0, 1
	n3 0, 0, 1
	material "white"
}
#left wall
triangle {
	v1 -5, 0, -5
	v2 -5, 0, 5
	v3 -5, 10, -5
	n1 1, 0, 0
	n2 1, 0, 0
	n3 1, 0, 0
	material "red"
}
triangle {
	v1 -5, 0, 5
	v2 -5, 10, 5
	v3 -5, 10, -5
	n1 1, 0, 0
	n2 1, 0, 0
	n3 1, 0, 0
	material "red"
}
#right wall
triangle {
	v1 5, 0, -5
	v2 5, 0, 5
	v3 5, 10, -5
	n1 -1, 0, 0
	n2 -1, 0, 0
	n3 -1, 0, 0
	material "blue"
}
triangle {
	v1 5, 0, 5
	v2 5, 10, 5
	v3 5, 10, -5
	n1 -1, 0, 0
	n2 -1, 0, 0
	n3 -1, 0, 0
	material "blue"
}
sphere
{
	center 2.5, 1.5, 2
	radius 1.5
	material "green"
}
sphere
{
	center -2, 2, -1
	radius 2
	material "mirror"
}
