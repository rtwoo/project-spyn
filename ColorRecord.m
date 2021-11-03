global reds greens blues;

% ! brick.SetColorMode(PORTS("Color"), 4);

reds = [];
greens = [];
blues = [];

t = timer;
t.TasksToExecute = 10;
t.ExecutionMode = 'fixedDelay';
t.TimerFcn = @record;
t.UserData = struct(...
	'Brick', brick...
);
start(t);

function record(src, ~)

	global reds greens blues;

	userData = src.UserData;
	brick = userData.Brick;
	
	colors = brick.ColorRGB(3);

	reds = [reds, double(colors(1))];
	greens = [greens, double(colors(2))];
	blues = [blues, double(colors(3))];
	disp("ran");

end