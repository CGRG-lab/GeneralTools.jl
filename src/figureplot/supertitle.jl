# see 
# https://stackoverflow.com/questions/43066957/adding-global-title-to-plots-jl-subplots
function supertitle(titlestr;size=(200,100),height=0.1)
"""
How to use:
	p1 = plot(h1,h2,size = (650,303));
	(title, layout) = supertitle("distribution of step sizes"; size = (200,100), height=0.1);
	plot(title,p1,layout=layout);
"""
	y = ones(3);
	title = Plots.scatter(y, marker=0,markeralpha=0, 
		annotations=(2, y[2], Plots.text(titlestr)),
		axis=false, leg=false,grid = false,size=size)
	return title, Plots.grid(2,1,heights = [height,1-height])
end