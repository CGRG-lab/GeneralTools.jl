"""
`rescale(vec0, [newlim0, newlim1])` rescale `vec0` on the new scale `[newlim0, newlim1]`.
"""
function rescale(vec0::Vector{<:Real}, vec2::Vector{<:Real})
	if length(vec2) != 2
		error("`vec2` should be a vector of exact two elements.");
	end
	intervals = vec0 |> diff;
	interval1 = intervals |> sum;
	diffv2 = diff(vec2);
	interval2 =  pop!(diffv2);

	sf = interval2/interval1; # scale factor
	int_scaled = sf*intervals;
	vec1 = [first(vec2), int_scaled...] |> cumsum
	return vec1
end