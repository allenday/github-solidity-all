options {
	# screen dimensions
	width	512
	height	512

	# other options
	bgcolor 0, 0, .2

	bspdepth 20
	bspleafobjs 6
}

# camera options
camera {
	lookat	 0, 2, 0
	pos	0, 5, 5
	up	0, 1, 0
	fov	55
}

pointlight {
	pos 0, 5, 1
	color 1, 1, 1
	wattage 100
}

material "red" {
	color 1,0,0
	diffuse 1
	specular 0
}

mesh {
  material "red"
  load "teapot_smooth.obj"
}
