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
		corner_clear_dist
		map_ports
		map_colors
		colorTol
		hasPickedUp
	end

	properties (Access = private)
		steer_mode
	end

	methods

		function obj = BotController(brick, driveSpeed, turnSpeed,...
			wheelDiam, turnDiam, steer_min, steer_max,...
			steer_amt, wall_dist_max, corner_clear_dist,...
			ports, colors, colorTol)

			obj.brick = brick;
			obj.b_inAuto = false;
			obj.b_inDrive = false;
			obj.driveSpeed = -driveSpeed;
			obj.turnSpeed = turnSpeed;
			obj.wheelDiam = wheelDiam;
			obj.turnDiam = turnDiam;
			obj.wheelCircum = wheelDiam * pi;
			obj.steer_min = steer_min;
			obj.steer_max = steer_max;
			obj.steer_amt = -steer_amt;
			obj.wall_dist_max = wall_dist_max;
			obj.corner_clear_dist = corner_clear_dist;
			obj.map_ports = ports;
			obj.map_colors = colors;
			obj.colorTol = colorTol;

			obj.steer_mode = "none";
			obj.hasPickedUp = false;

		end

		function beginNav(obj)
			
			colorReset = true;
			obj.b_inAuto = true;
			wallSeen = false;

			while obj.b_inAuto

				% STEP 1: COLOR ZONE DETECTION
				colorZone = obj.checkForColor();
				disp(colorZone);
	
				switch(colorZone)
					case 'STOP'
						if colorReset
							colorReset = false;
							obj.stopDrive();
							pause(4);
							obj.steer_mode = "none";
						end
					case 'PICKUP'
						if ~obj.hasPickedUp
							% enter manual controller
							obj.stopDrive();
							AdvancedController(obj);
							obj.b_inAuto = false;
							continue;
						end
					case 'DROPOFF'
						if obj.hasPickedUp
							obj.stopDrive();
							% enter manual controller
							AdvancedController(obj);
							obj.b_inAuto = false;
							continue;
						end
					case 'STREET'
						if ~colorReset
							colorReset = true;
						end
				end

				ultraDist = obj.brick.UltrasonicDist(obj.map_ports('ULTRA'));
				turnTouch = obj.brick.TouchPressed(obj.map_ports('TOUCH'));
				killTouch = obj.brick.TouchPressed(obj.map_ports('KILL'));

				if ultraDist < obj.wall_dist_max && ~wallSeen
					disp("tracking wall");
					wallSeen = true;
				end

				% STEP 2: TURNING
				if ultraDist > obj.wall_dist_max && wallSeen

					disp("left turn");
					numRot = obj.corner_clear_dist / obj.wheelCircum;
					rightMotor = obj.map_ports('RIGHT_MOTOR');
					leftMotor = obj.map_ports('LEFT_MOTOR');
					obj.brick.StopAllMotors('Coast');
					obj.brick.MoveMotorAngleRel(strcat(rightMotor, leftMotor), obj.driveSpeed, numRot * 360, 'Coast');
					obj.waitForMotors();
					obj.turnLeft();
					obj.startDrive(obj.driveSpeed, obj.driveSpeed);
					wallSeen = false;
					disp("no longer tracking wall");
					obj.steer_mode = "none";

				elseif turnTouch

					disp("right turn");
					obj.stopDrive();
					obj.startDrive(-obj.driveSpeed, -obj.driveSpeed);
					pause(0.25);
					obj.turnRight();
					obj.steer_mode = "none";

				elseif killTouch

					obj.b_inAuto = false;
					obj.brick.StopAllMotors();
					continue;
					
				end

				% STEP 3: DRIVING & STEERING
				if wallSeen

						if ultraDist > obj.steer_min && ultraDist < obj.steer_max
							% steer straight
							if obj.steer_mode ~= "straight"
								% power both motors equally
								disp("straight");
								obj.startDrive(obj.driveSpeed, obj.driveSpeed);
								obj.steer_mode = "straight";
							end
						else
							if ultraDist < obj.steer_min
								% steer away
								if obj.steer_mode ~= "away"
									% reduce power on right motor
									disp("away");
									obj.startDrive(obj.driveSpeed - obj.steer_amt, obj.driveSpeed);
									obj.steer_mode = "away";
								end
							elseif ultraDist > obj.steer_max
								% steer toward
								if obj.steer_mode ~= "toward"
									% reduce power on left motor
									disp("toward");
									obj.startDrive(obj.driveSpeed, obj.driveSpeed - obj.steer_amt);
									obj.steer_mode = "toward";
								end
							end
						end

				end

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

		function colorZone = checkForColor(obj)

			colorZone = 'STREET';
			currentColor = obj.brick.ColorRGB(obj.map_ports('COLOR'));

			k = keys(obj.map_colors);
			v = values(obj.map_colors);
			for i = 1:length(obj.map_colors)
				redCheck = abs(double(currentColor(1)) - v{i}(1)) < obj.colorTol;
				greenCheck = abs(double(currentColor(2)) - v{i}(2)) < obj.colorTol;
				blueCheck = abs(double(currentColor(3)) - v{i}(3)) < obj.colorTol; 
				if redCheck && greenCheck && blueCheck
					colorZone = k{i};
					break;
				end
			end

		end

	end

	methods (Access = private)

		function obj = startDrive(obj, rightSpeed, leftSpeed)
			rightMotor = obj.map_ports("RIGHT_MOTOR");
			leftMotor = obj.map_ports("LEFT_MOTOR");
			obj.brick.MoveMotor(rightMotor, rightSpeed);
			obj.brick.MoveMotor(leftMotor, leftSpeed);
			obj.b_inDrive = true;
		end
		
		function obj = stopDrive(obj)
			obj.brick.StopAllMotors('Brake');
			obj.steer_mode = "none";
			obj.b_inDrive = false;
		end
		
		function turn(obj, degrees, direction)

			obj.stopDrive();
			
			radian = obj.turnDiam / 2;
			turnDist = deg2rad(degrees) * radian;
			numRot = turnDist / obj.wheelCircum;

			dirSpeed = obj.turnSpeed;
			if direction == "LEFT"
				dirSpeed = -dirSpeed;
			end

			rightMotor = obj.map_ports('RIGHT_MOTOR');
			leftMotor = obj.map_ports('LEFT_MOTOR');

			obj.brick.MoveMotorAngleRel(rightMotor, dirSpeed, numRot * 360, 'Brake');
			obj.brick.MoveMotorAngleRel(leftMotor, -dirSpeed, numRot * 360, 'Brake');
			obj.waitForMotors();

		end
		
		function turnRight(obj)

			% radian = obj.turnDiam / 2;
			% turnDist = pi / 2 * radian;
			% numRot = turnDist / obj.wheelCircum;

			% rightMotor = obj.map_ports("RIGHT_MOTOR");
			% leftMotor = obj.map_ports("LEFT_MOTOR");

			% obj.brick.MoveMotorAngleRel(rightMotor, obj.turnSpeed, numRot * 360, 'Brake');
			% obj.brick.MoveMotorAngleRel(leftMotor, -obj.turnSpeed, numRot * 360, 'Brake');
			% obj.waitForMotors();

			obj.turn(90, "RIGHT");

		end
		
		function turnLeft(obj)

			% radian = obj.turnDiam / 2;
			% turnDist = pi / 2 * radian;
			% numRot = (turnDist * 0.9) / obj.wheelCircum;

			% rightMotor = obj.map_ports("RIGHT_MOTOR");
			% leftMotor = obj.map_ports("LEFT_MOTOR");

			% obj.brick.MoveMotorAngleRel(rightMotor, -obj.turnSpeed, numRot * 360, 'Brake');
			% obj.brick.MoveMotorAngleRel(leftMotor, obj.turnSpeed, numRot * 360, 'Brake');
			% obj.waitForMotors();

			obj.turn(90, "LEFT");

		end
		
		function turnAbout(obj)

			% radian = obj.turnDiam / 2;
			% turnDist = pi * radian;
			% numRot = turnDist / obj.wheelCircum;

			% rightMotor = obj.map_ports("RIGHT_MOTOR");
			% leftMotor = obj.map_ports("LEFT_MOTOR");

			% obj.brick.MoveMotorAngleRel(rightMotor, obj.turnSpeed, numRot * 360, 'Brake');
			% obj.brick.MoveMotorAngleRel(leftMotor, -obj.turnSpeed, numRot * 360, 'Brake');
			% obj.waitForMotors();

			obj.turn(180, "RIGHT");

		end
		
		function waitForMotors(obj)
			rightMotor = obj.map_ports("RIGHT_MOTOR");
			leftMotor = obj.map_ports("LEFT_MOTOR");
			obj.brick.WaitForMotor(strcat(rightMotor, leftMotor));
		end         
            
		% ! DEPRECATED, not needed in new nav algorithm
		% % * this should only used if the bot is stopped
		% function [rightOpen, leftOpen] = contactScan()
			
		% 	rightOpen = brick.UltrasonicDist(PORTS("ULTRA")) > DIST_OPEN;
		% 	turnAbout();
		% 	leftOpen = brick.UltrasonicDist(PORTS("ULTRA")) > DIST_OPEN;
		% 	turnAbout();

		% end

	end

end