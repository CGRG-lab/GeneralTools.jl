# see 
# https://stackoverflow.com/questions/43066957/adding-global-title-to-plots-jl-subplots
"""
`supertitle(titletext; kw...)`
Create plot axes for super title.

# Arguments
	`titletext`
	- title string, e.g. "My title"
	- Input argument of `text`, i.e. `annotate!(..., text(titletext...))`. 
	- For example, one can define `titletext = L"F=ma", 48)`, which results in `annotate!([(..., text(L"F=ma", 48))])`

# How to use:
	p1 = plot(...);
	(title, layout) = supertitle("distribution of step sizes"; size = (200,100), height=0.1);
	plot(title,p1,layout=layout);
	
# Options: 
    size: specifying the size of the superlegend axis
    - if larger size is specified,
        - the font size will be smaller 
        - the upper white edge will be larger
        
    height: determine the ratio of height of the upper axes to the whole. Default is 0.1 (axes for super title has 0.1, and the main plot has 0.9, for `plot(p1,title,...))`.
    
    ylim: you can set the distance between legend strings to the subplot below and to the edge of the very top. Default is [0,0]

"""
function supertitle(titletext;size=(200,100),height=0.1, ylim=[0,0])
	y = zeros(3);
	# line, scatter, heatmap, etc all just pass through to the plot function. You can imagine it looks like:
	# vline(args...; kw...) = plot(args...; kw..., seriestype = :vline)
	if isa(titletext, String) || isa(titletext, LaTeXString)
		titletext = (titletext,);
	end
	title = Plots.scatter(y, marker=0,markeralpha=0, 
		ylim = ylim,
		axis=false, leg=false,grid = false,ticks = nothing,size=size); # annotations=(2, y[2], Plots.text(titletext)),
	annotate!(title, [(2.0, y[2], Plots.text(titletext...))])
	return title, Plots.grid(2,1,heights = [height,1-height])
end