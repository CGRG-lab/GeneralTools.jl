# Tools for DataFrame Processing

defaultchkfn = (ismissing, isnothing, isnan);

"""
`filtern` works based on `filter` automatically drop rows where the corresponding specific column `col1` contains `NaN`, `missing` or `nothing`. 

`filtern(col1, df)` is the shorthand of `filter(cols => fun, df::AbstractDataFrame)` where `fun` is for examing whether the column contains `NaN`, `missing` or `nothing`.
"""
function filtern!(col, df; chkfun=defaultchkfn)
	# see this thread: https://stackoverflow.com/questions/62789334/how-to-remove-drop-rows-of-nothing-and-nan-in-julia-dataframe
	return filter!(col => c1 -> !any(f -> f(c1), chkfun), df)
end

"""
`filtern(col1, col2, df)` automatically drop rows where either of `col1` and `col2`  contains `NaN`, `missing` or `nothing`. 
"""
function filtern!(col1, col2, df; chkfun=defaultchkfn)
	return filter!([col1, col2] => (c1, c2) -> !any(f -> f(c1) || f(c2), chkfun), df)
end