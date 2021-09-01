"""
`ind = nearestbelow(array, nearto)` return the indices for the elements in `array` that are nearest below `nearto`.
The nearest elements are `array[ind]`.
# Example
julia> nearestbelow([1,2,3,4,5,6],[1.9, 3.3])
2-element Vector{Float64}:
 1
 3
"""
function nearestbelow(array::Vector{<:Real}, nearto::Vector{<:Real})
	ind = Vector{Int64}(undef,length(nearto));
	for (i,target) in enumerate(nearto)
		ind[i] = findlast(array .<= target);
	end
	return ind
end