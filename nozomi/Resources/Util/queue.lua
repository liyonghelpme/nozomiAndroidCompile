queue = nil
do
	local function createQueue(max)
		local q={}
		local head, tail = 0, 0
		local sizeMax = max
	
		local function pop()
			if head<tail then
				local value = q[head]
				q[head] = nil
				head = head+1
				return value
			end
		end
	
		local function size()
			return tail-head
		end
	
		local function push(value)
			q[tail] = value
			tail = tail+1
			if sizeMax and size()>sizeMax then
				pop()
			end
		end
	
		local function clear()
			q = {}
			head, tail = 0, 0
		end
	
		local function get(index)
			return q[tail-(index or 1)]
		end
	
		return {push = push, pop = pop, size=size, clear = clear, get = get}
	end
	
	queue = {create = createQueue}
end