"""
`superlegend()` creates a super legend.
How to use:

	p1 = plot(...);
    strings = ["data1", "data2", "data3"];
    plotopts = [
                (seriestype = :line, ),
                (seriestype = :line, ),
                (seriestype = :scatter, color = :red)
                ];
    
    lgd,layout = superlegend(strings)
	plot(p1,lgd, layout = layout, size = p[:size])
    # redefine plot size is required if legend is put at the bottom.

Options: 
    size: specifying the size of the superlegend axis
    - if larger size is specified,
        - the font size will be smaller 
        - the upper white edge will be larger
        
    height: determine the ratio of height of the upper axes to the whole. Default is 0.97 (main plot has 0.97, and super-legend axis has 0.03, for `plot(p1,lgd,...))``.
    
    ylim: you can set the distance between legend strings to the subplot below and to the edge of the very top. Default is [-1.5,-1.5]
    
    fontsize: Default is 7
    
    lrmargin: Left- and right margin; default is 25 (in unit of Plots.mm)
    
    plotopts: plot options
    
    linewidth: specifying an overall linewidth.
"""
function superlegend(strings;plotopts=0,size=(180,21), ylim=[-1,1], fontsize = 10, texthalign = :left,height = 0.97, lrmargin = 25)
    # strings = ["FIM","Nx","FricC"]
    # plotopts = [(seriestype = :line,), (seriestype = :line,), (seriestype = :scatter,)]
    lenstr = length(strings);
    
    if isequal(plotopts,0)
        plotopts = [];
        for i = 1:lenstr
            push!(plotopts, (seriestype=:line,));
        end
    end
    
    
    if lenstr == length(plotopts)
    
    else
        error("The number of strings and number of plot options has to be identical");
    end
    
    npoints = 2*lenstr + 1;
	y = zeros(npoints);
    x = collect(1.0:npoints);
	# line, scatter, heatmap, etc all just pass through to the plot function. You can imagine it looks like:
	# vline(args...; kw...) = plot(args...; kw..., seriestype = :vline)
    annotations = []
    for i = 1:lenstr
        push!(annotations, "");
        push!(annotations, Plots.text(strings[i], texthalign, fontsize));
    end
    push!(annotations, "");
    
    annoopts = [];
    for i = 1:npoints
        push!(annoopts, (x[i], y[i], annotations[i]));
    end
    
    splegend = Plots.scatter(x, y, marker=5,    
        markeralpha=0,  legend_columns = 3,
		ylim = ylim, size=size, annotations = annoopts,
		axis=false, grid = false, legend=false,
        ticks = nothing);
        
        
    for i = 1:lenstr
        xi0 = x[2i-1];
        xi1 = 0.2*x[2i-1] + 0.8*x[2i];
        yi0 = y[2i-1];
        yi1 = y[2i];
        plot!(splegend,[xi0, xi1],[yi0,yi1];plotopts[i]...);
    end
    p = plot(splegend, framestyle = :box, axis = true, left_margin = lrmargin*Plots.mm, right_margin = lrmargin*Plots.mm, bottom_margin = -1Plots.mm, top_margin = -1Plots.mm);
	return p, Plots.grid(2,1,heights = [height,1-height])
end