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
% 		steer_min
% 		steer_max
		steer_val
		steer_amt
		wall_dist_max
		map_ports
		map_colors
		colorTol
	end

	properties (Access = private)
		steer_mode
		hasPickedUp
	end

	methods

		function obj = BotController(brick, driveSpeed, turnSpeed,...
			wheelDiam, turnDiam, steer_val, steer_amt, wall_dist_max, ports, colors, colorTol)

			obj.brick = brick;
			obj.b_inAuto = false;
			obj.b_inDrive = false;
			obj.driveSpeed = driveSpeed;
			obj.turnSpeed = turnSpeed;
			obj.wheelDiam = wheelDiam;
			obj.turnDiam = turnDiam;
			obj.wheelCircum = wheelDiam * pi;
% 			obj.steer_min = steer_min;
% 			obj.steer_max = steer_max;
			obj.steer_val = steer_val;
			obj.steer_amt = steer_amt;
			obj.wall_dist_max = wall_dist_max;
			obj.map_ports = ports;
			obj.map_colors = colors;
			obj.colorTol = colorTol;

			obj.steer_mode = "none";
			obj.hasPickedUp = false;

		end
		
		function circum = getCircum(obj)
			circum = obj.wheelDiam * pi;
		end

		function beginNav(obj)

			obj.b_inAuto = true;
			while obj.b_inAuto

				% STEP 1: COLOR ZONE DETECTION
				% colorZone = obj.checkForColor();
				% switch(colorZone)
				% 	case "STOP"
				% 		obj.stopDrive();
				% 		pause(4);
				% 	case "PICKUP"
				% 		if ~obj.hasPickedUp
				% 			% enter manual controller
				% 			AdvancedController(obj);
				% 			obj.b_inAuto = false;
				% 			continue;
				% 		end
				% 	case "DROPOFF"
				% 		if obj.hasPickedUp
				% 			% enter manual controller
				% 			AdvancedController(obj);
				% 			obj.b_inAuto = false;
				% 			continue;
				% 		end
				% end

				ultraDist = obj.brick.UltrasonicDist(obj.map_ports("Ultra"));
				turnTouch = obj.brick.TouchPressed(obj.map_ports("Touch"));
				killTouch = obj.brick.TouchPressed(obj.map_ports("Kill"));

				% STEP 2: TURNING
				if ultraDist > obj.wall_dist_max
					pause(1);
					obj.stopDrive();
					obj.turnLeft();
					obj.startDrive(obj.driveSpeed, obj.driveSpeed);
					pause(1);
				elseif turnTouch
					obj.stopDrive();
					obj.startDrive(-obj.driveSpeed, -obj.driveSpeed);
					pause(1);
					obj.turnRight();
				elseif killTouch
					obj.b_inAuto = false;
					obj.brick.StopAllMotors();
					continue;
				end
				
				% STEP 3: DRIVING & STEERING
				if ultraDist < obj.steer_val
					% steer away
					if obj.steer_mode ~= "away"
						% reduce power on right motor
						disp("away");
						obj.startDrive(obj.driveSpeed - obj.steer_amt, obj.driveSpeed);
						obj.steer_mode = "away";
					end
				elseif ultraDist > obj.steer_val
					% steer toward
					if obj.steer_mode ~= "toward"
						% reduce power on left motor
						disp("toward");
						obj.startDrive(obj.driveSpeed, obj.driveSpeed - obj.steer_amt);
						obj.steer_mode = "toward";
					end
				end

% 				if ultraDist > obj.steer_min && ultraDist < obj.steer_max
% 					if obj.steer_mode ~= "straight"
% 						% equally power motors
% 						disp("straight");
% 						obj.startDrive(obj.driveSpeed, obj.driveSpeed);
% 						obj.steer_mode = "straight";
% 					end
% 				else
% 					if ultraDist < obj.steer_min
% 						if obj.steer_mode ~= "away"
% 							% reduce power on right motor
% 							disp("away");
% 							obj.startDrive(obj.driveSpeed - -10, obj.driveSpeed);
% 							obj.steer_mode = "away";
% 						end
% 					elseif ultraDist > obj.steer_min
% 						if obj.steer_mode ~= "toward"
% 							% reduce power on left motor
% 							disp("toward");
% 							obj.startDrive(obj.driveSpeed, obj.driveSpeed - -10);
% 							obj.steer_mode = "toward";
% 						end
% 					end
% 				end

			end
			
		end

		function p_driveTest(obj, rightSpeed, leftSpeed, duration)
			obj.startDrive(rightSpeed, leftSpeed);
			pause(duration);
			obj.stopDrive();
		end

		function p_turnRight(obj)
			obj.turnRight();
		end

		function p_turnLeft(obj)
			obj.turnLeft();
		end

		function p_turn(obj, degrees, direction)
			obj.turn(degrees, direction);
		end

	end

	methods (Access = private)

		function obj = startDrive(obj, rightSpeed, leftSpeed)
			rightMotor = obj.map_ports("RightMotor");
			leftMotor = obj.map_ports("LeftMotor");
			obj.brick.MoveMotor(rightMotor, rightSpeed);
			obj.brick.MoveMotor(leftMotor, leftSpeed);
			obj.b_inDrive = true;
		end
		
		function obj = stopDrive(obj)
			obj.brick.StopAllMotors("Brake");
			obj.steer_mode = "none";
			obj.b_inDrive = false;
		end
		
		function turn(obj, degrees, direction)

			radian = obj.turnDiam / 2;
			turnDist = deg2rad(degrees) * radian;
			numRot = turnDist / obj.wheelCircum;

			dirSpeed = obj.turnSpeed;
			if direction == "LEFT"
				dirSpeed = -dirSpeed;
			end

			rightMotor = obj.map_ports("RightMotor");
			leftMotor = obj.map_ports("LeftMotor");

			obj.brick.MoveMotorAngleRel(rightMotor, dirSpeed, numRot * 360, "Brake");
			obj.brick.MoveMotorAngleRel(leftMotor, -dirSpeed, numRot * 360, "Brake");
			obj.waitForMotors();

		end
		
		function turnRight(obj)

			radian = obj.turnDiam / 2;
			turnDist = pi / 2 * radian;
			numRot = turnDist / obj.wheelCircum;

			rightMotor = obj.map_ports("RightMotor");
			leftMotor = obj.map_ports("LeftMotor");

			obj.brick.MoveMotorAngleRel(rightMotor, obj.turnSpeed, numRot * 360, "Brake");
			obj.brick.MoveMotorAngleRel(leftMotor, -obj.turnSpeed, numRot * 360, "Brake");
			obj.waitForMotors();

		end
		
		function turnLeft(obj)

			radian = obj.turnDiam / 2;
			turnDist = pi / 2 * radian;
			numRot = turnDist / obj.wheelCircum;

			rightMotor = obj.map_ports("RightMotor");
			leftMotor = obj.map_ports("LeftMotor");

			obj.brick.MoveMotorAngleRel(rightMotor, -obj.turnSpeed, numRot * 360, "Brake");
			obj.brick.MoveMotorAngleRel(leftMotor, obj.turnSpeed, numRot * 360, "Brake");
			obj.waitForMotors();

		end
		
		function turnAbout(obj)

			radian = obj.turnDiam / 2;
			turnDist = pi * radian;
			numRot = turnDist / obj.wheelCircum;

			rightMotor = obj.map_ports("RightMotor");
			leftMotor = obj.map_ports("LeftMotor");

			obj.brick.MoveMotorAngleRel(rightMotor, obj.turnSpeed, numRot * 360, "Brake");
			obj.brick.MoveMotorAngleRel(leftMotor, -obj.turnSpeed, numRot * 360, "Brake");
			obj.waitForMotors();

		end
		
		function waitForMotors(obj)
			rightMotor = obj.map_ports("RightMotor");
			leftMotor = obj.map_ports("LeftMotor");
			obj.brick.WaitForMotor(strcat(rightMotor, leftMotor));
		end
		
		% ! UNUSED
		function open = leftScan(obj)
			open = obj.brick.UltrasonicDist(PORTS("Ultra")) > DIST_OPEN;
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
					colorZone = k{i};
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