function botInit()
	global inAuto wheelCircum turnDiam;
	inAuto = true;
	wheelDiam = 5.5;
	wheelCircum = pi * wheelDiam;
end

function turn(degrees)

end

function turnRight()
	global wheelCircum, turnDiam;
	radian = turnDiam / 2;
	turnDist = pi / 2 * radian;
	numRot = turnDist / wheelCircum;
	% power left for numRot rotations
	% power right for -numRot rotations
end

function turnLeft()

end

function turnAbout()

end

function stop(duration)
	
end