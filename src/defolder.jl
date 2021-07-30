"""
`defolder(dir)`
Delete all empty folders left everytime we use the `weave(...)`.
"""
function defolder(dir::AbstractString="output")
	flist = readdir(joinpath(pwd(),dir), join=true);
	dirtrue = isdir.(flist);
	fmtmatched = .!isnothing.(match.(r"jl_[A-Za-z0-9]{6}",flist));
	rm.(flist[dirtrue .& fmtmatched]);
end