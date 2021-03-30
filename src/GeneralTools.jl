module GeneralTools
    filesep = Base.Filesystem.path_separator;
    export filesep
# using
	# using Plots
	
# include
	include("datalist.jl");
	include("openit.jl");
	include("back2.jl");
	include("figureplot/supertitle.jl");
	export datalist
	export back2
	export supertitle
	
end
