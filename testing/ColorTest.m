colorPort = 3;
drivePorts = 'DA';
armPort = 'C';
driveSpeed = 15;
% brick.SetColorMode(colorPort, 4);

testing = true;
lookForColors = true;
colorCode = 'table';
actingOn = 'table';
reset = true;

pause(3);
while testing

	color = brick.ColorRGB(colorPort);
	% disp(color);

	if color(1) <= 10 && color(2) <= 10 && color(3) <= 10
		if ~strcmp(colorCode, 'black')
			colorCode = 'black';
			lookForColors = true;
			disp("looking");
		end
	elseif lookForColors

			% wait until the bot is on the center of the rectangle to check color
			pause(0.2);
			if color(1) > 50
				if color(2) < 50
					colorCode = 'red';
				elseif color(2) > 50 && color(3) < 50
					colorCode = 'yellow';
				else
					colorCode = 'white';
				end
			else
				if color(3) > 12 && color(3) < 20
					colorCode = 'blue';
				elseif color(3) < 12
					colorCode = 'green';
				else
					colorCode = 'table';
				end
			end

% 			if ~(strcmp(actingOn, colorCode))
% 				switch(colorCode)
% 					case 'yellow'
% 						% start driving
% 						if reset
% % 							brick.MoveMotor(drivePorts, driveSpeed);
% 							reset = false;
% 						end
% 					case 'red'
% 						if reset
% % 							brick.StopAllMotors();
% 							pause(4);
% % 							brick.MoveMotor(drivePorts, driveSpeed);
% 							reset = false;
% 							testing = false;
% 						end
% 					case 'green'
% 						% raise arm
% 					case 'blue'
% 						% lower arm
% 						testing = false;
% 					case 'table'
% 						disp("reset");
% 						reset = true;
% 				end
% 				disp(colorCode);
% 		end
% 		actingOn = colorCode;
			
		if ~strcmp(colorCode, 'black')
			lookForColors = false;
			switch(colorCode)
				case 'yellow'
					brick.MoveMotor(drivePorts, driveSpeed);
					disp("Acted Yellow");
				case 'red'
					brick.StopAllMotors();
					pause(4);
					brick.MoveMotor(drivePorts, driveSpeed);
					disp("Acted Red");
				case 'green'
% 						lift arm
					brick.StopAllMotors();
					brick.MoveMotorAngleRel(armPort, 50, 15, 'Coast');
					brick.WaitForMotor(armPort);
					brick.MoveMotor(drivePorts, driveSpeed);
					disp("Acted Green");
				case 'blue'
					brick.StopAllMotors();
					brick.MoveMotorAngleRel(armPort, -50, 15, 'Coast');
					brick.WaitForMotor(armPort);
					testing = false;
					disp("Acted Blue");
			end
		end
			
	end
	disp(colorCode);

end