colorPort = 3;
drivePorts = 'DA';
armPort = 'C';
driveSpeed = 15;
brick.SetColorMode(colorPort, 2);

nav = true;
actingOn = 1;
blackSeen = 0;

while nav
	
	color = brick.ColorCode(colorPort);
	disp(color);
	
	if ~(actingOn == color)
		switch(color)
			case 7	
				% yellow
				brick.MoveMotor(drivePorts, driveSpeed);
			case 5
				% red
				brick.StopAllMotors('Brake');
				pause(4);
				brick.MoveMotor(drivePorts, driveSpeed);
			case 1
				switch(blackSeen) 
					case 0
						blackSeen = blackSeen + 1;
					case 1
						firstTime = false;
						brick.StopAllMotors('Brake');
						disp("lifting arm");
						brick.MoveMotorAngleRel(armPort, -50, 25, 'Coast');
% 						brick.WaitForMotor(armPort);
						pause(0.5);
						brick.MoveMotor(drivePorts, driveSpeed);
						blackSeen = blackSeen + 1;
					case 2
						brick.StopAllMotors('Brake');
						disp("lowering arm");
						brick.MoveMotorAngleRel(armPort, 50, 25, 'Coast');
% 						brick.WaitForMotor(armPort);
						nav = false;
				end
		end
		disp(color);
	end
	actingOn = color;

end