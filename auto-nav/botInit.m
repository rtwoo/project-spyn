function botInit(brick)

	% set up color sensor to be RGB
	brick.SetColorMode(PORTS('Color'), 4);

	driveSpeed = 25;
	turnSpeed = 50;
	wheelDiam = 5.715;
	turnDiam = 12.065;
	ports = containers.Map(...
	{'RightMotor', 'LeftMotor', 'Touch', 'Ultra', 'Color'},...
	{'D'         , 'A'        , '1'    , '2'    , '3'});
	colors = containers.Map(...
	{'STOP'     , 'PICKUP' , 'DROPOFF'},...
	{[255, 0, 0], [0, 255, 0], [0, 0, 255]});
	
	bot = BotController(brick, driveSpeed, turnSpeed, wheelDiam, turnDiam, ports, colors);
	bot.beginNav();

end