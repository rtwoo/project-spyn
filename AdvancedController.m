% global brick right left speed inForward inReverse inLeft inRight inTurnLeft inTurnRight inBrake;
fig = figure('Name', 'EV3 Controller', 'KeyPressFcn', @handleKeyDown, 'KeyReleaseFcn', @handleKeyUp);
% brick = brickConnection;
right = 'D';
left = 'A';
loader = 'C';
speed = 100;
loaderSpeed = 10;

% [inForward, inReverse, inLeft, inRight, inTurnLeft, inTurnRight] = deal(false);

motorStates = containers.Map(...
	{'inForward', 'inReverse', 'inLeft', 'inRight', 'inTurnLeft', 'inTurnRight', 'inBrake', 'inRaise', 'inLower'},...
	{false, false, false, false, false, false, false, false, false});

fig.UserData = struct(...
	"Brick", brick,...
	"Right", right,...
	"Left", left,...
	"Loader", loader,...
	"Speed", speed,...
	"LoaderSpeed", loaderSpeed,...
	"MotorStates", motorStates...
);

function handleKeyDown(src, event)

	userData = ancestor(src, "figure", "toplevel").UserData;
	brick = userData.Brick;
	right = userData.Right;
	left = userData.Left;
	loader = userData.Loader;
	speed = userData.Speed;
	loaderSpeed = userData.LoaderSpeed;
	motorStates = userData.MotorStates; 
	% global brick right left speed inForward inReverse inLeft inRight inTurnLeft inTurnRight inBrake;
	% fprintf("Pressed: " + event.Key + "\n");
	switch event.Key

		case 'w' % forward
			if ~motorStates('inForward')
				overrideMovement(motorStates);
				brick.MoveMotor(strcat(right, left), speed);
				fprintf("brick.MoveMotor(right + left, speed)\n");
				motorStates('inForward') = true;
			end
		case 's' % reverse
			if ~motorStates('inReverse')
				overrideMovement(motorStates);
				brick.MoveMotor(strcat(right, left), -speed);
				fprintf("brick.MoveMotor(right + left, -speed)\n");
				motorStates('inReverse') = true;
			end
		case 'a' % left
			if motorStates('inForward')
				if ~motorStates('inTurnLeft')
					motorStates('inTurnRight') = false;
					brick.MoveMotor(left, speed);
					fprintf("brick.MoveMotor(right, speed)\n");
					brick.MoveMotor(right, 0.5 * speed);
					fprintf("brick.MoveMotor(left, 0.75 * speed)\n");
					motorStates('inTurnLeft') = true;
				end
			elseif motorStates('inReverse')
				if ~motorStates('inTurnLeft')
					motorStates('inTurnRight') = false;
					brick.MoveMotor(right, -speed);
					brick.MoveMotor(left, 0.5 * -speed);
					motorStates('inTurnLeft') = true;
				end
			elseif ~motorStates('inLeft')
				overrideMovement(motorStates);
				brick.MoveMotor(right, speed);
				fprintf("brick.MoveMotor(right, speed)\n");
				brick.MoveMotor(left, -speed);
				fprintf("brick.MoveMotor(left, -speed)\n");
				motorStates('inLeft') = true;
			end
		case 'd' % right
			if motorStates('inForward')
				if ~motorStates('inTurnRight')
					motorStates('inTurnLeft') = false;
					brick.MoveMotor(left, 0.5 * speed);
					fprintf("brick.MoveMotor(right, 0.75 * speed)\n");
					brick.MoveMotor(right, speed);
					fprintf("brick.MoveMotor(left, speed)\n");
					motorStates('inTurnRight') = true;
				end
			elseif motorStates('inReverse')
				if ~motorStates('inTurnRight')
					motorStates('inTurnLeft') = false;
					brick.MoveMotor(right, 0.5 * -speed);
					brick.MoveMotor(left, -speed);
					motorStates('inTurnRight') = true;
				end
			elseif ~motorStates('inRight')
				overrideMovement(motorStates);
				brick.MoveMotor(left, speed);
				fprintf("brick.MoveMotor(left, speed)\n");
				brick.MoveMotor(right, -speed);
				fprintf("brick.MoveMotor(right, -speed)\n");
				motorStates('inRight') = true;
			end
		case 'space'
			if ~motorStates('inBrake')
				brick.StopAllMotors('Brake');
				fprintf("brick.StopAllMotors('Brake')\n");
				motorStates('inBrake') = true;
			end
		case 'semicolon'
			if ~motorStates('inRaise')
				brick.MoveMotor(loader, loaderSpeed);
				motorStates('inRaise') = true;
				motorStates('inLower') = false;
			end
		case 'quote'
			if ~motorStates('inLower')
				brick.MoveMotor(loader, -loaderSpeed);
				motorStates('inLower') = true;
				motorStates('inRaise') = false;
			end

	end

end

function handleKeyUp(src, event)

	userData = ancestor(src, "figure", "toplevel").UserData;
	brick = userData.Brick;
	right = userData.Right;
	left = userData.Left;
	loader = userData.Loader;
	speed = userData.Speed;
	motorStates = userData.MotorStates; 
	% global brick right left inForward inReverse inLeft inRight inTurnLeft inTurnRight inBrake;
	% fprintf("Released: " + event.Key + "\n");
	switch event.Key

		case 'w' % forward
			if motorStates('inForward')
					brick.StopMotor(strcat(right, left), 'Coast');
					fprintf("brick.StopMotor(right + left, 'Coast')\n");
					overrideMovement(userData.MotorStates);
			end
		case 's' % reverse
			if motorStates('inReverse')
					brick.StopMotor(strcat(right, left), 'Coast');
					fprintf("brick.StopMotor(right + left, 'Coast')\n");
					motorStates('inReverse') = false;
			end
		case 'a' % left
			if motorStates('inForward') && motorStates('inTurnLeft')
				brick.MoveMotor(right, speed);
				fprintf("brick.MoveMotor(left, speed)\n");
				motorStates('inTurnLeft') = false;
			elseif motorStates('inReverse') && motorStates('inTurnLeft')
				brick.MoveMotor(left, -speed);
				motorStates('inTurnLeft') = false;
			elseif motorStates('inLeft')
					brick.StopMotor(right, 'Coast');
					fprintf("brick.StopMotor(right, 'Coast')\n");
					brick.StopMotor(left, 'Coast');
					fprintf("brick.StopMotor(left, 'Coast')\n");
					motorStates('inLeft') = false;
			end
		case 'd' % right
			if motorStates('inForward') && motorStates('inTurnRight')
					brick.MoveMotor(left, speed);
					fprintf("brick.MoveMotor(right, speed)\n");
					motorStates('inTurnRight') = false;
			elseif motorStates('inReverse') && motorStates('inTurnRight')
					brick.MoveMotor(right, -speed);
					motorStates('inTurnRight') = false;
			elseif motorStates('inRight')
					brick.StopMotor(left, 'Coast');
					fprintf("brick.StopMotor(left, 'Coast')\n");
					brick.StopMotor(right, 'Coast');
					fprintf("brick.StopMotor(right, 'Coast')\n");
					motorStates('inRight') = false;
			end
		case 'space'
			if motorStates('inBrake')
				motorStates('inBrake') = false;
			end
		case 'semicolon'
			if motorStates('inRaise')
				motorStates('inRaise') = false;
				if ~motorStates('inLower')
					brick.StopMotor(loader, 'Coast');
				end
			end
		case 'quote'
			if motorStates('inLower')
				motorStates('inLower') = false;
			end
			if ~motorStates('inRaise')
					brick.StopMotor(loader, 'Coast');
			end
	
	end
    
end

function overrideMovement(motorStates)
	k = keys(motorStates);
	for i = 1:length(motorStates)
		motorStates(k{i}) = false;
	end
end