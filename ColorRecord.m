% ! brick.SetColorMode(PORTS("Color"), 4);

reds = [];
greens = [];
blues = [];

t = timer;
t.TasksToExecute = 10;
t.ExecutionMode = 'fixedDelay';
t.TimerFcn = @record;
t.UserData = struct(...
	'Brick', brick,...
	'Reds', reds,...
	'Greens', greens,...
	'Blues', blues...
);
start(t);

function record(src, ~)

	userData = src.UserData;
	brick = userData.Brick;
	reds = userData.Reds;
	greens = userData.Greens;
	blues = userData.Blues;
	
	colors = brick.ColorRGB();

	reds = [reds, colors(1)];
	greens = [greens, colors(2)];
	blues = [blues, colors(3)];

end