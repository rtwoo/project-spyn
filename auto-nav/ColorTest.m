colorPort = 3;
drivePorts = 'DA';
armPort = 'C';
driveSpeed = 15;
brick.SetColorMode(colorPort, 4);

testing = true;
lookForColors = true;
colorCode = 'black';

pause(3);
while testing

	color = brick.ColorRGB(colorPort);
	disp(color);

	if color(1) < 10 && color(2) < 10 && color(3) < 10
		if ~strcmp(colorCode, 'black')
			colorCode = 'black';
			lookForColors = true;
		end
	elseif lookForColors

			pause(0.1);
			if color(1) > 50
				if color(2) < 50
					colorCode = 'red';
				elseif color(2) > 50 && ~(color(3) > 50)
					colorCode = 'yellow';
				end
			else
				if color(3) > 10
					colorCode = 'blue';
				elseif color(3) < 10
					colorCode = 'green';
				end
			end
			
			if ~strcmp(colorCode, 'black')
				lookForColors = false;
				switch(colorCode)
					case 'yellow'
						brick.MoveMotor(drivePorts, -driveSpeed);
					case 'red'
						brick.StopAllMotors();
						pause(4);
						brick.MoveMotor(drivePorts, -driveSpeed);
					case 'green'
						% lift arm
						brick.StopAllMotors();
						brick.MoveMotorAngleRel(armPort, 50, 15, 'Brake');
						brick.WaitForMotor(armPort);
						brick.MoveMotor(drivePorts, -10);
					case 'blue'
						brick.StopAllMotors();
						brick.MoveMotorAngleRel(armPort, -50, 15, 'Brake');
						brick.WaitForMotor(armPort);
						testing = false;
				end
			end
			
		end
	end
	disp(colorCode);

end