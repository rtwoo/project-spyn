function botInit()
	global IN_AUTO IN_DRIVE WHEEL_CIRCUM TURN_DIAM TURN_SPEED DRIVE_SPEED PORTS COLORS;
	% set up color sensor to be RGB
	IN_AUTO = true;
	IN_DRIVE = false;
	wheelDiam = 5.5;
	WHEEL_CIRCUM = pi * wheelDiam;
	% PORTS = map
	% COLORS = map
end

function startDrive()
	brick.MoveMotor(strcat(PORTS('RightMotor'), PORTS('LeftMotor')), DRIVE_SPEED);
end

function stopDrive()
	brick.StopAllMotors('Brake');
end

function turn(degrees, direction)
	global WHEEL_CIRCUM TURN_DIAM TURN_SPEED;
	radian = TURN_DIAM / 2;
	turnDist = deg2rad(degrees) * radian;
	numRot = turnDist / WHEEL_CIRCUM;
	dirSpeed = TURN_SPEED;
	if diretion == 'LEFT'
		dirSpeed = -dirSpeed;
	end
	brick.MoveMotorAngleRel(PORTS('RightMotor'), -TURN_SPEED, numRot * 360, 'Brake');
	brick.MoveMotorAngleRel(PORTS('LeftMotor'), TURN_SPEED, numRot * 360, 'Brake');
end

function turnRight()
	global WHEEL_CIRCUM TURN_DIAM TURN_SPEED;
	radian = TURN_DIAM / 2;
	turnDist = pi / 2 * radian;
	numRot = turnDist / WHEEL_CIRCUM;
	brick.MoveMotorAngleRel(PORTS('RightMotor'), -TURN_SPEED, numRot * 360, 'Brake');
	brick.MoveMotorAngleRel(PORTS('LeftMotor'), TURN_SPEED, numRot * 360, 'Brake');
end

function turnLeft()
	global WHEEL_CIRCUM TURN_DIAM TURN_SPEED;
	radian = TURN_DIAM / 2;
	turnDist = pi / 2 * radian;
	numRot = turnDist / WHEEL_CIRCUM;
	brick.MoveMotorAngleRel(PORTS('RightMotor'), TURN_SPEED, numRot * 360, 'Brake');
	brick.MoveMotorAngleRel(PORTS('LeftMotor'), -TURN_SPEED, numRot * 360, 'Brake');
end

function turnAbout()
	global WHEEL_CIRCUM TURN_DIAM TURN_SPEED;
	radian = TURN_DIAM / 2;
	turnDist = pi * radian;
	numRot = turnDist / WHEEL_CIRCUM;
	brick.MoveMotorAngleRel(PORTS('RightMotor'), TURN_SPEED, numRot * 360, 'Brake');
	brick.MoveMotorAngleRel(PORTS('LeftMotor'), -TURN_SPEED, numRot * 360, 'Brake');
end

% TODO: maybe just use sleep(seconds)
function stop(duration)
	
end