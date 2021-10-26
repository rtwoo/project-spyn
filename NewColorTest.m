colorPort = 3;
drivePorts = 'DA';
armPort = 'C';
driveSpeed = 15;
brick.SetColorMode(colorPort, 2);

nav = true;
actingOn = 1;
firstTime = true;

while nav
	
	color = brick.ColorCode(colorPort);
	
	if ~(actingOn == color)
		switch(color)
			case 4	
				% yellow
				brick.MoveMotor(drivePorts, driveSpeed);
			case 5
				% red
				brick.StopAllMotors();
				pause(4);
				brick.MoveMotor(drivePorts, driveSpeed);
			case 1
				if firstTime
					firstTime = false;
					disp("lifting arm");
					brick.StopAllMotors();
					% lift arm
					brick.MoveMotor(drivePorts, driveSpeed);
				else
					% lower arm
					brick.StopAllMotors();
					disp("lowering arm");
					nav = false;
				end
		end
		disp(color);
	end
	actingOn = color;

end