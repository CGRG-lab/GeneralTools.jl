"""
Add/update GeneralTools at https://github.com/CGRG-lab/GeneralTools.jl.git
"""
module GeneralTools 
# usually git ignore manifest if this is a package for using, 
# because usually dependencies on a specific version of other package (e.g. Plots) is not necessary, 
# and if Manifest.toml is uploaded to github, people may have to install two different versions of Plots, resulting in confliction.
    filesep = Base.Filesystem.path_separator;
    export filesep
# using
	# Whenever you apply `using ACertainPackage` here, make sure that package is added to Project.toml. 
	# That is, `(GeneralTools) pkg> add ACertainPackage`
	# Otherwise, it will fail when you use GeneralTools.jl in other place. 
	
# include
	include("datalist.jl");
	include("openit.jl");
	include("back2.jl");
	include("circles.jl");
	include("findfirstfromlast.jl");
	include("cdfE.jl")
	include("getext.jl");
	using Plots # you have to add Plots under this environment, i.e. (GeneralTools) pkg> add Plots
	# supertitle will fail without using Plots here, 
	# even when `using Plots` has been applied in your script.
	using LaTeXStrings
	include("figureplot/supertitle.jl");
	include("figureplot/superlegend.jl");
	include("textprocessing/tex.jl");
	using Markdown
	include("textprocessing/weavehugo.jl");
	using DataFrames
	include("preview.jl");
	using InteractiveUtils: clipboard # this is required for df2latex.jl
	include("textprocessing/df2latex.jl");
	include("targetlist.jl");
	include("nearestbelow.jl");
	using Compose
	include("figureplot/composetools.jl");
	export datalist
	export back2
	export supertitle
	export superlegend
	export openit
	export findfirstfromlast
	export cdfE
	export getext
	export removesection!
	export removecomment!
	export pushback
	export preview, middle
	export df2latex
	export targetlist
	export nearestbelow
	
	# in weavehugo.jl
	using Weave
	export lazyhugo
	export cp2content
	export getdoc
	export defolder
	include("textprocessing/renamefile.jl");
	export renamefile
	
	# in composetools.jl
	export myarrow
	export pos2points
	export pointshift
	export composelabels
	export ctparent
	export ctchildheight
	export ctchildwidth
	
	using Gadfly
	include("dfprocessing.jl"); 
	export filtern!
	export forsegplot
	
	include("rescale.jl")
	export rescale
	
	# in filelist.jl
	include("filelist.jl")
	export filelist

	using DataFrames
	include("dfvstack.jl")
	export dfvstack

	using CSV
	include("skipwrite.jl")
	export skipwrite
end
