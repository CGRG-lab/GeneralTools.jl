"""
`df2latex(df::DataFrame, outpath::AbstractString)` generates the latex table according to the dataframe.
The result is copied to clipboard; nothing will be returned.
"""
function df2latex(df::DataFrame)
	str = let
		io = IOBuffer();
		show(io, MIME("text/latex"), df);
		str = String(take!(io))
	end
	clipboard(str);
	nothing
end