function findfirstfromlast(arr_Bool)
	for i in Iterators.reverse(eachindex(arr_Bool))
		if arr_Bool[i]
			return i
		end
	end
	
# 0.5 to 2 times slower:
# function findfirstfromlast1b(arr_Bool);
# revind = Iterators.reverse(eachindex(arr_Bool));
# v = findfirst(arr_Bool[revind]);
# return revind[v]
# end
end