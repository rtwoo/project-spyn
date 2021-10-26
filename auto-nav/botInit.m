function botInit(brick)
	global IN_AUTO IN_DRIVE WHEEL_CIRCUM TURN_DIAM TURN_SPEED DRIVE_SPEED PORTS COLORS;
	% set up color sensor to be RGB
	IN_AUTO = true;
	IN_DRIVE = false;
	wheelDiam = 5.715;
	WHEEL_CIRCUM = pi * wheelDiam;
	TURN_DIAM = 12.065;
	DRIVE_SPEED = 25;
	TURN_SPEED = 50;
	PORTS = containers.Map(...
	{'RightMotor', 'LeftMotor', 'Touch', 'Ultra', 'Color'},...
	{'D'         , 'A'        , '1'    , '2'    , '3'});
	COLORS = containers.Map(...
	{'STOP'     , 'PICKUP' , 'DROPOFF'},...
	{[255, 0, 0], [0, 255, 0], [0, 0, 255]});
	brick.SetColorMode(PORTS('Color'), 4);

	turnRight();
	turnLeft();
	turnLeft();
% 	turnAbout();

	function startDrive()
		brick.MoveMotor(strcat(PORTS('RightMotor'), PORTS('LeftMotor')), DRIVE_SPEED);
		IN_DRIVE = true;
	end
	
	function stopDrive()
		brick.StopAllMotors('Brake');
		IN_DRIVE = false;
	end
	
	function turn(degrees, direction)
		radian = TURN_DIAM / 2;
		turnDist = deg2rad(degrees) * radian;
		numRot = turnDist / WHEEL_CIRCUM;
		dirSpeed = TURN_SPEED;
		if strcmp(direction, 'LEFT')
			dirSpeed = -dirSpeed;
		end
		brick.MoveMotorAngleRel(PORTS('RightMotor'), dirSpeed, numRot * 360, 'Brake');
		brick.MoveMotorAngleRel(PORTS('LeftMotor'), -dirSpeed, numRot * 360, 'Brake');
		waitForMotors();
	end
	
	function turnRight()
		radian = TURN_DIAM / 2;
		turnDist = pi / 2 * radian;
		numRot = turnDist / WHEEL_CIRCUM;
		brick.MoveMotorAngleRel(PORTS('RightMotor'), TURN_SPEED, numRot * 360, 'Brake');
		brick.MoveMotorAngleRel(PORTS('LeftMotor'), -TURN_SPEED, numRot * 360, 'Brake');
		waitForMotors();
		fprintf("ran\n");
	end
	
	function turnLeft()
		radian = TURN_DIAM / 2;
		turnDist = pi / 2 * radian;
		numRot = turnDist / WHEEL_CIRCUM;
		brick.MoveMotorAngleRel(PORTS('RightMotor'), -TURN_SPEED, numRot * 360, 'Brake');
		brick.MoveMotorAngleRel(PORTS('LeftMotor'), TURN_SPEED, numRot * 360, 'Brake');
		waitForMotors();
	end
	
	function turnAbout()
		radian = TURN_DIAM / 2;
		turnDist = pi * radian;
		numRot = turnDist / WHEEL_CIRCUM;
		brick.MoveMotorAngleRel(PORTS('RightMotor'), TURN_SPEED, numRot * 360, 'Brake');
		brick.MoveMotorAngleRel(PORTS('LeftMotor'), -TURN_SPEED, numRot * 360, 'Brake');
		waitForMotors();
	end
	
	% TODO: maybe just use sleep(seconds)
	function stop(duration)
		
	end
	
	function waitForMotors()
		brick.WaitForMotor(strcat(PORTS('RightMotor'), PORTS('LeftMotor')));
	end
	
	function open = rightScan()
		open = brick.UltrasonicDist(PORTS('Ultra')) > DIST_OPEN;
	end
	
	% * this should only used if the bot is stopped
	function [rightOpen, leftOpen] = contactScan()
		
		rightOpen = brick.UltrasonicDist(PORTS('Ultra')) > DIST_OPEN;
		turnAbout();
		leftOpen = brick.UltrasonicDist(PORTS('Ultra')) > DIST_OPEN;
		turnAbout();
	end

end