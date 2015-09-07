class 'DelayedEvents'

function DelayedEvents:__init(trigger)
	self.events	= {}
	self.timer	= Timer()
	self.tick	= trigger or "PreTick"
	Events:Subscribe("DelayedEvent", self, self.AddEvent)
end

-- ####################################################################################################################################

function DelayedEvents:AddEvent(args)
	args.exp = (args.delay or args.time) + self.timer:GetMilliseconds()
	if (#self.events == 0) then
		table.insert(self.events, args)
		self.sub = Events:Subscribe(self.tick, self, self.Ticker)
	else
		for i = #self.events, 0, -1 do		-- may faster that way
			if (i == 0) or (self.events[i].exp <= args.exp) then
				table.insert(self.events, i + 1, args)
				break
			end
		end
	end
end

function DelayedEvents:Ticker(args)
	time = self.timer:GetMilliseconds()
	while 1 do
		if self.events[1] and (self.events[1].exp <= time) then
			item = self.events[1]			-- needed to call the remove function first...
			table.remove(self.events, 1)	-- avoids crashing the script in case of marshalling error
			if (#self.events == 0) then Events:Unsubscribe(self.sub) end
			Events:Fire(item.event, item.args)
		else
			break
		end
	end
end
