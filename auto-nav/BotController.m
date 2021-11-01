classdef BotController

	properties
		brick
		b_inAuto
		b_inDrive
		driveSpeed
		turnSpeed
		wheelDiam
		turnDiam
		wheelCircum
		steer_min
		steer_max
		steer_amt
		wall_dist_max
		map_ports
		map_colors
		colorTol
	end

	properties (Access = private)
		steer_mode
	end

	methods

		function obj = BotController(brick, driveSpeed, turnSpeed,...
			wheelDiam, turnDiam, steer_min, steer_max, steer_amt, opening_dist, ports, colors, colorTol)

			obj.brick = brick;
			obj.b_inAuto = false;
			obj.b_inDrive = false;
			obj.driveSpeed = driveSpeed;
			obj.turnSpeed = turnSpeed;
			obj.wheelDiam = wheelDiam;
			obj.turnDiam = turnDiam;
			obj.wheelCircum = wheelDiam * pi;
			obj.steer_min = steer_min;
			obj.steer_max = steer_max;
			obj.steer_amt = steer_amt;
			obj.wall_dist_max = wall_dist_max;
			obj.map_ports = ports;
			obj.map_colors = colors;
			obj.colorTol = colorTol;

			obj.steer_mode = "none"

		end
		
		function circum = getCircum(obj)
			circum = obj.diam * pi;
		end

		function beginNav(obj)

			obj.b_inAuto = true;
			while obj.b_inAuto

				colorZone = obj.checkForColor();
				switch(colorZone)
					case "STOP"
						obj.stopDrive();
						pause(4);
					case "PICKUP"
						if ~obj.hasPickedUp
							% enter manual controller
							obj.b_inAuto = false;
							continue;
						end
					case "DROPOFF"
						if obj.hasPickedUp
							% enter manual controller
							obj.b_inAuto = false;
							continue;
						end
				end

				ultraDist = obj.brick.UltrasonicDist(obj.map_ports("ULTRA"));

				if ultraDist > obj.wall_dist_max;
					pause(1);
					obj.stopDrive();
					obj.turnLeft();
					obj.startDrive(obj.driveSpeed, obj.driveSpeed);
					pause(1);
				elseif obj.brick.TouchPressed(obj.map_ports("TOUCH"))
					obj.stopDrive();
					obj.turnRight();
				end
				
				if ultraDist < obj.steer_min && obj.steer_mode ~= "away"
					% reduce power on right motor
					obj.startDrive(obj.driveSpeed - obj.steer_amt, obj.drivespeed);
					obj.steer_mode = "away";
				elseif ultraDist > obj.steer_max && obj.steer_mode ~= "toward"
					% reduce power on left motor
					obj.startDrive(obj.driveSpeed, obj.drivespeed - obj.steer_amt);
					obj.steer_mode = "toward";
				elseif obj.steer_mode ~= "straight"
					% equally power motors
					obj.startDrive(obj.driveSpeed, obj.driveSpeed);
					obj.steer_mode = "straight"
				end

			end
			
		end
		
	end

	methods (Access = private)

		function startDrive(obj, rightSpeed, leftSpeed)
			rightMotor = obj.map_ports("RightMotor");
			leftMotor = obj.map_ports("LeftMotor");
			obj.brick.MoveMotor(rightMotor, rightSpeed);
			obj.brick.MoveMotor(leftMotor, leftSpeed);
			obj.b_inDrive = true;
		end
		
		function stopDrive(obj)
			obj.brick.StopAllMotors("Brake");
			obj.steer_mode = "none";
			obj.b_inDrive = false;
		end
		
		function turn(obj, degrees, direction)
			radian = obj.turnDiam / 2;
			turnDist = deg2rad(degrees) * radian;
			numRot = turnDist / obj.wheelCircum;
			dirSpeed = obj.turnSpeed;
			if strcmp(direction, "LEFT")
				dirSpeed = -dirSpeed;
			end
			obj.brick.MoveMotorAngleRel(obj.map_ports("RightMotor"), dirSpeed, numRot * 360, "Brake");
			obj.brick.MoveMotorAngleRel(obj.map_ports("LeftMotor"), -dirSpeed, numRot * 360, "Brake");
			waitForMotors();
		end
		
		function turnRight(obj)
			radian = obj.turnDiam / 2;
			turnDist = pi / 2 * radian;
			numRot = turnDist / obj.wheelCircum;
			obj.brick.MoveMotorAngleRel(obj.map_ports("RightMotor"), TURN_SPEED, numRot * 360, "Brake");
			obj.brick.MoveMotorAngleRel(obj.map_ports("LeftMotor"), -TURN_SPEED, numRot * 360, "Brake");
			waitForMotors();
		end
		
		function turnLeft(obj)
			radian = obj.turnDiam / 2;
			turnDist = pi / 2 * radian;
			numRot = turnDist / obj.wheelCircum;
			obj.brick.MoveMotorAngleRel(obj.map_ports("RightMotor"), -TURN_SPEED, numRot * 360, "Brake");
			obj.brick.MoveMotorAngleRel(obj.map_ports("LeftMotor"), TURN_SPEED, numRot * 360, "Brake");
			waitForMotors();
		end
		
		function turnAbout()
			radian = obj.turnDiam / 2;
			turnDist = pi * radian;
			numRot = turnDist / obj.wheelCircum;
			brick.MoveMotorAngleRel(obj.map_ports("RightMotor"), TURN_SPEED, numRot * 360, "Brake");
			brick.MoveMotorAngleRel(obj.map_ports("LeftMotor"), -TURN_SPEED, numRot * 360, "Brake");
			waitForMotors();
		end
		
		function waitForMotors(obj)
			rightMotor = obj.map_ports("RightMotor");
			leftMotor = obj.map_ports("LeftMotor");
			brick.WaitForMotor(strcat(rightMotor, leftMotor));
		end
		
		function open = leftScan()
			open = brick.UltrasonicDist(PORTS("Ultra")) > DIST_OPEN;
		end
        
		function colorZone = checkForColor(obj)

			colorZone = "STREET";
			currentColor = obj.brick.ColorRGB();

			k = keys(obj.map_colors);
			v = values(obj.map_colors);
			for i = 1:length(obj.map_colors)
				redCheck = abs(currentColor(1) - v{i}(1)) < obj.colorTol;
				greenCheck = abs(currentColor(2) - v{i}(2)) < obj.colorTol;
				blueCheck = abs(currentColor(3) - v{i}(3)) < obj.colorTol; 
				if redCheck && greenCheck && blueCheck
					colorZone = key{i};
					break
				end
			end
			
		end                 
            
		% ! DEPRECATED, not needed in new nav algorithm
		% % * this should only used if the bot is stopped
		% function [rightOpen, leftOpen] = contactScan()
			
		% 	rightOpen = brick.UltrasonicDist(PORTS("Ultra")) > DIST_OPEN;
		% 	turnAbout();
		% 	leftOpen = brick.UltrasonicDist(PORTS("Ultra")) > DIST_OPEN;
		% 	turnAbout();

		% end

	end

end