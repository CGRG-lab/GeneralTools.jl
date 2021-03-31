module GeneralTools
    filesep = Base.Filesystem.path_separator;
    export filesep
# using
	# using Plots
	
# include
	include("datalist.jl");
	include("openit.jl");
	include("back2.jl");
	
	using Plots 
	# supertitle will fail without using Plots here, 
	# even when `using Plots` has been applied in your script.
	include("figureplot/supertitle.jl");
	
	export datalist
	export back2
	export supertitle
	
end
