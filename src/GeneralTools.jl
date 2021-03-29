module GeneralTools
	modulename = "GeneralTools.jl"; # must the same with above.
    filesep = Base.Filesystem.path_separator;
    export filesep

# include
	include("datalist.jl");
	include("eventFilter.jl");
	include("openit.jl");
	include("back2.jl");
end
