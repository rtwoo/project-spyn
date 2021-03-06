

function AdvancedController(botController)
% function AdvancedController()

	fig = figure('Name', 'EV3 Controller', 'KeyPressFcn', @handleKeyDown, 'KeyReleaseFcn', @handleKeyUp);
	right = 'D';
	left = 'A';
	loader = 'C';
	global advDriveSpeed;
	advDriveSpeed = 10;
	turnSpeed = 10;
	loaderSpeed = 3;
	brick = botController.brick;
% 	brick = 0;
% 	botController = 0;

	motorStates = containers.Map(...
		{'inForward', 'inReverse', 'inLeft', 'inRight', 'inTurnLeft', 'inTurnRight', 'inBrake', 'inRaise', 'inLower'},...
		{false, false, false, false, false, false, false, false, false});

	t = timer;
	t.ExecutionMode = 'fixedDelay';
	t.TimerFcn = @beep;
	t.UserData = struct(...
		'Brick', brick...
	);

	fig.UserData = struct(...
		'Brick', brick,...
		'Right', right,...
		'Left', left,...
		'Loader', loader,...
		'TurnSpeed', turnSpeed,...
		'LoaderSpeed', loaderSpeed,...
		'MotorStates', motorStates,...
		'BeepTimer', t,...
		'BotController', botController...
	);

	function handleKeyDown(src, event)

		userData = ancestor(src, 'figure', 'toplevel').UserData;
		brick = userData.Brick;
		right = userData.Right;
		left = userData.Left;
		loader = userData.Loader;
		speed = advDriveSpeed;
		turnSpeed = advDriveSpeed;
		loaderSpeed = userData.LoaderSpeed;
		motorStates = userData.MotorStates;
		beep = userData.BeepTimer;
		controller = userData.BotController;
% 		fprintf("Pressed: " + event.Key + "\n");
		
		switch event.Key

			case 'w' % forward
				if ~motorStates('inForward')
					disp(speed);
					overrideMovement(motorStates);
					brick.MoveMotor(strcat(right, left), speed);
					motorStates('inForward') = true;
				end
			case 's' % reverse
				if ~motorStates('inReverse')
					overrideMovement(motorStates);
					brick.MoveMotor(strcat(right, left), -speed);
					motorStates('inReverse') = true;
					start(beep);
				end
			case 'a' % left
				if motorStates('inForward')
					if ~motorStates('inTurnLeft')
						motorStates('inTurnRight') = false;
						brick.MoveMotor(left, speed);
						brick.MoveMotor(right, 0.25 * speed);
						motorStates('inTurnLeft') = true;
					end
				elseif motorStates('inReverse')
					if ~motorStates('inTurnLeft')
						motorStates('inTurnRight') = false;
						brick.MoveMotor(right, -speed);
						brick.MoveMotor(left, 0.25 * -speed);
						motorStates('inTurnLeft') = true;
					end
				elseif ~motorStates('inLeft')
					overrideMovement(motorStates);
					brick.MoveMotor(left, turnSpeed);
					brick.MoveMotor(right, -turnSpeed);
					motorStates('inLeft') = true;
				end
			case 'd' % right
				if motorStates('inForward')
					if ~motorStates('inTurnRight')
						motorStates('inTurnLeft') = false;
						brick.MoveMotor(left, 0.25 * speed);
						brick.MoveMotor(right, speed);
						motorStates('inTurnRight') = true;
					end
				elseif motorStates('inReverse')
					if ~motorStates('inTurnRight')
						motorStates('inTurnLeft') = false;
						brick.MoveMotor(right, 0.25 * -speed);
						brick.MoveMotor(left, -speed);
						motorStates('inTurnRight') = true;
					end
				elseif ~motorStates('inRight')
					overrideMovement(motorStates);
					brick.MoveMotor(right, turnSpeed);
					brick.MoveMotor(left, -turnSpeed);
					motorStates('inRight') = true;
				end
			case 'space'
				if ~motorStates('inBrake')
					brick.StopAllMotors('Brake');
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
			case 'comma'
				% reduce speed
				advDriveSpeed = advDriveSpeed - 5;
				if advDriveSpeed <= 0
					advDriveSpeed = 5;
				end
				fprintf("Speed: " + advDriveSpeed + "\n");
			case 'period'
				advDriveSpeed = advDriveSpeed + 5;
				if advDriveSpeed > 100
					advDriveSpeed = 100;
				end
				fprintf("Speed: " + advDriveSpeed + "\n");
			case 'escape'
				close(src);
				if ~controller.hasPickedUp
					controller.hasPickedUp = true;
					controller.beginNav();
				end
		end

	end

	function handleKeyUp(src, event)

		userData = ancestor(src, 'figure', 'toplevel').UserData;
		brick = userData.Brick;
		right = userData.Right;
		left = userData.Left;
		loader = userData.Loader;
		speed = advDriveSpeed;
		turnSpeed = userData.TurnSpeed;
		motorStates = userData.MotorStates;
		beep = userData.BeepTimer;
		% fprintf('Released: ' + event.Key + '\n');

		switch event.Key

			case 'w' % forward
				if motorStates('inForward')
						brick.StopMotor(strcat(right, left), 'Coast');
						overrideMovement(userData.MotorStates);
				end
			case 's' % reverse
				if motorStates('inReverse')
						brick.StopMotor(strcat(right, left), 'Coast');
						motorStates('inReverse') = false;
						stop(beep);
				end
			case 'a' % left
				if motorStates('inForward') && motorStates('inTurnLeft')
					brick.MoveMotor(right, speed);
					motorStates('inTurnLeft') = false;
				elseif motorStates('inReverse') && motorStates('inTurnLeft')
					brick.MoveMotor(left, -speed);
					motorStates('inTurnLeft') = false;
				elseif motorStates('inLeft')
						brick.StopMotor(strcat(right, left), 'Coast');
						motorStates('inLeft') = false;
				end
			case 'd' % right
				if motorStates('inForward') && motorStates('inTurnRight')
						brick.MoveMotor(left, speed);
						motorStates('inTurnRight') = false;
				elseif motorStates('inReverse') && motorStates('inTurnRight')
						brick.MoveMotor(right, -speed);
						motorStates('inTurnRight') = false;
				elseif motorStates('inRight')
						brick.StopMotor(strcat(right, left), 'Coast');
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
					if ~motorStates('inRaise')
							brick.StopMotor(loader, 'Coast');
					end
				end
		
		end
			
	end

	function overrideMovement(motorStates)
		k = keys(motorStates);
		for i = 1:length(motorStates)
			if ~strcmp(k{i}, 'inRaise') && ~strcmp(k{i}, 'inLower')
				motorStates(k{i}) = false;
			end
		end
	end

	function beep(src, ~)
		userData = src.UserData;
		% disp("beeping");
		brick = userData.Brick;
		brick.playTone(100, 1000, 500);
	end
	
end