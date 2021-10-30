colorPort = 3;
drivePorts = 'DA';
armPort = 'C';
driveSpeed = 15;
brick.SetColorMode(colorPort, 2);

nav = true;
actedOn = 0;

while nav
	
	color = brick.ColorCode(colorPort);
	disp(color);
	
	% avoid acting on the same color multiple times
	if color ~= actedOn
		switch(color)
			case 4	
				disp("Yellow: Starting Navigation");
				brick.MoveMotor(drivePorts, driveSpeed);
			case 5
				disp("Red: Stopping for 4 seconds...")
				brick.StopAllMotors('Brake');
				pause(4);
				brick.MoveMotor(drivePorts, driveSpeed);
			case 3
				brick.StopAllMotors('Brake');
				disp("Green: Simulating Pickup");
				brick.MoveMotorAngleRel(armPort, -50, 25, 'Coast');
				brick.WaitForMotor(armPort);
				% pause(0.5);
				brick.MoveMotor(drivePorts, driveSpeed);
			case 2
				brick.StopAllMotors('Brake');
				disp("Blue: Simulating Dropoff");
				brick.MoveMotorAngleRel(armPort, 50, 25, 'Coast');
				brick.WaitForMotor(armPort);
				% end navigation
				nav = false;
			end
		end
		% disp(color);
	end
	actedOn = color;

end