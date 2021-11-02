driveSpeed = -30;
turnSpeed = 25;
wheelDiam = 5.715;
turnDiam = 12.065;
% steer_min = 12;
% steer_max = 15;
steer_val = 16;
steer_amt = driveSpeed * 0.2;
% 	steer_amt_away = -10;
% 	steer_amt_towards = -4;
wall_dist_max = 40;
ports = containers.Map(...
{'RightMotor', 'LeftMotor', 'Touch', 'Ultra', 'Color', 'Kill'},...
{'D'          , 'A'         , 4      , 2      , 3      , 1     });
colors = containers.Map(...
{'STOP'     , 'PICKUP'   , 'DROPOFF'  , 'FOURTH' },...
{[70, 10, 10], [-500, -500, -500], [-500, -500, -500], [-500, -500, -500]});
colorTol = 20;

bot = BotController(brick, driveSpeed, turnSpeed,...
				wheelDiam, turnDiam, steer_val, steer_amt, wall_dist_max, ports, colors, colorTol);
% 	bot.beginNav();