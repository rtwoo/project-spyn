% * make sure you"ve run "brick = ConnectBrick("pogger")" before executing this script
function init(brick)

	% set up color sensor to be RGB
	brick.SetColorMode(PORTS("Color"), 4);

	driveSpeed = 25;
	turnSpeed = 50;
	wheelDiam = 5.715;
	turnDiam = 12.065;
	steer_min = 12;
	steer_max = 21;
	steer_amt = 10;
	wall_dist_max = 70;
	ports = containers.Map(...
	{"RightMotor", "LeftMotor", "Touch", "Ultra", "Color"},...
	{"D"         , "A"        , "1"    , "2"    , "3"});
	colors = containers.Map(...
	{"STOP"     , "PICKUP" , "DROPOFF"},...
	{[255, 0, 0], [0, 255, 0], [0, 0, 255]});
	colorTol = 20;
	
	bot = BotController(brick, driveSpeed, turnSpeed,...
					wheelDiam, turnDiam, steer_min, steer_max, steer_amt, wall_dist_max, ports, colors, colorTol)
	bot.beginNav();

end