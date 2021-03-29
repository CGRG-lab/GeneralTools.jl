module GeneralTools
    filesep = Base.Filesystem.path_separator;
    export filesep
# include
	include("datalist.jl");
	include("openit.jl");
	include("back2.jl");
	export datalist
	export back2
	
end
