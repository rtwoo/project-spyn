% * make sure you've run 'brick = ConnectBrick("pogger")' before executing this script
% global IN_AUTO IN_DRIVE WHEEL_CIRCUM TURN_DIAM TURN_SPEED DRIVE_SPEED PORTS COLORS;

botInit();
init();

function init()

	while IN_AUTO
		
		% make sure color sensor checks aren't expensive
		% if they are add a delay to this check
		color_rgb = brick.ColorRGB(SensorPort);
		if color_rgb == COLORS('STOP')
			pause(3) % stop for 3 seconds
		elseif color_rgb == COLORS('PICKUP') || color_rgb == COLORS('DROPOFF')
			IN_AUTO = false;
			startAdvControl();
		end

		if ~IN_DRIVE
			startDrive();
		end

		if brick.TouchPressed(PORTS('Touch'))
			stopDrive();
			[rightOpen, leftOpen] = contactScan();
			if rightOpen
				turnRight();
			elseif leftOpen
				turnLeft();
			else
				turnAbout();
			end
		elseif rightScan()
			% maybe don't turn immediately, move forward a bit more
			% it might be worth measuring where the hallway opening starts and ends
			% to position the bot in the middle of the opening before turning
			stopDrive();
			turnRight();
		end
			
	end
	
end