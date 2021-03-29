# go back to the nth parent directory
function back2(this_path, n)
return back2_core(this_path, n)
end

# go back to the ith parent directory and precede to directory_ahead
function back2(this_path, n, directory_ahead)
this_path = back2_core(this_path, n);
return joinpath(this_path,directory_ahead)
end

function back2_core(this_path, n)
for i = 1:n
	this_path = dirname(this_path);
end
return this_path
end
