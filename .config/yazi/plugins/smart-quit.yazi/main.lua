return {
	entry = function(self, job)
		if os.getenv("YAZI_FLOAT") then
			ya.emit("quit", {})
		end
	end,
}
