options {
	# screen dimensions
	width	512
	height	512

	# other options
	bgcolor 0, 0, .2

	bspdepth 1
	bspleafobjs 20
}

# camera options
camera {
	lookat	 0, 0, 0
	pos	5, 8, 5
	up	0, 1, 0
	fov	45
}

pointlight
{
    pos 2, 8, 2
    color 1, 1, 1
    wattage 400
}

material "red" {
	color 1,0,0
	diffuse .6
	specular .5
}
#triangle {
#	v1 -10, 0, 10
#	v2 10, 0, 10
#	v3 10, 0, -10
#	n1 0, 1, 0
#	n2 0, 1, 0
#	n3 0, 1, 0
#}
#triangle {
#	v1 -10, 0, -10
#	v2 10, 0, -10
#	v3 -10, 0, 10
#	n1 0, 1, 0
#	n2 0, 1, 0
#	n3 0, 1, 0
#}
sphere
{
    center 0, 1, 0
    radius 1.0
	material "red"
}
sphere
{
    center 3, 1.0,0
    radius 1.0
	material "red"
}
sphere
{
    center 6, 1.0,0
    radius 1.0
	material "red"
}
sphere
{
    center 9, 1.0,0
    radius 1.0
	material "red"
}
sphere
{
    center 0, 1.0,3 
    radius 1.0
	material "red"
}
sphere
{
    center 3, 1.0,3
    radius 1.0
	material "red"
}
sphere
{
    center 6, 1.0, 3
    radius 1.0
	material "red"
}
#sphere
#{
#    center 6, 3.0,4
#    radius 1.0
#color 1,0,0
#diffuse .5
#specular .5
#}
sphere
{
    center 4, 3.5,1 
    radius 1.0
	material "red"
}
sphere
{
    center 2, 2.0,-2 
    radius 1.0
	material "red"
}
sphere
{
    center 9, 3,6
    radius 1.0
	material "red"
}
sphere
{
    center 6, 3.0,3.5 
    radius 1.0
	material "red"
}
sphere
{
    center 6, 3.0,0
    radius 1.0
	material "red"
}
sphere
{
    center -3, 1.0,4.5 
    radius 1.0
	material "red"
}
sphere
{
    center -3.5, 1.0,8.5 
    radius 1.0
	material "red"
}
sphere
{
    center -2.5, 4.0,9.5 
    radius 1.0
	material "red"
}
sphere
{
    center -9.5, 1.0,3.5 
    radius 1.0
	material "red"
}
sphere
{
    center -6.5, 5.0,-2.5 
    radius 1.0
	material "red"
}
