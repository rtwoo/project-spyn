%============%
%   CONFIG   %
%============%

% motor power percentage when driving (1-100)
driveSpeed = 30;
% motor power percentage when turning (1-100)
turnSpeed = 25;

% wheel diameter (cm)
wheelDiam = 5.715;
% distance between wheels (cm)
turnDiam = 12.065;

% desired distance from wall when steering (cm)
steer_min = 14;
steer_max = 16;
% motor power reduction when steering
steer_amt = driveSpeed * 0.2;

% maximum allowed distance from wall before left turn is performed
wall_dist_max = 45;
corner_clear_dist = 28.5;

ports = containers.Map(...
{'RIGHT_MOTOR', 'LEFT_MOTOR', 'TOUCH', 'ULTRA', 'COLOR', 'KILL'},...
{'D'          , 'A'         , 4      , 2      , 3      , 1     });
colors = containers.Map(...
{'STOP'     , 'PICKUP'   , 'DROPOFF'  , 'START' },...
{[70, 10, 10], [10, 20, 40], [15, 35, 15], [85, 45, 15]});
% red, blue, yellow, green
colorTol = 10;

% BotController constructor
bot = BotController(brick, driveSpeed, turnSpeed,...
				wheelDiam, turnDiam, steer_min, steer_max,...
				steer_amt, wall_dist_max, corner_clear_dist,...
				ports, colors, colorTol);
% 	bot.beginNav();