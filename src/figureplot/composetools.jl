"""
Coordinate transform function `ctparent` convert the coordinates of `point = (x1, y1)` on a child frame `c1` to its corresponding coordinates `(x0, y0)` on a parent frame `c0`. 

For example, 
saying you have a circle centered at `(x1, y1)` of the coordinate system `c1`, where `c1` is located on `contextdim` of `c0`:
```julia
c0 = context();
c1 = context(contextdim...;units=UnitBox(0,0,2,2));
circle1 = circle(x1,y1,0.1);
compose(c0, (c1, circle1));
```
Using the transformed coordinates `(x0,y0)=ctparent((x1,y1),contextdim;UnitBox=(0,0,2,2))` we can draw the same circle as `circle1` by `compose(c0, circle(x0,y0,0.1))`.
"""
function ctparent(point::NTuple{2,<:Real},contextdim::NTuple{4,<:Real};UnitBox::NTuple{4,<:Real}=(0,0,1,1))
    x1, y1 = point;
    xstart1a, ystart1a, width1a, height1a = contextdim;
    xstart1b, ystart1b, width1b, height1b = UnitBox;
    Δx1 = x1-xstart1b;
    Δy1 = y1-ystart1b;
    cfactorx = width1a/1; # default context()'s width/height is 1
    cfactory = height1a/1; 
    ubfactorx = 1/width1b; # default UnitBox()'s width/height is 1
    ubfactory = 1/height1b;
    x0 = xstart1a + Δx1*cfactorx*ubfactorx;
    y0 = ystart1a + Δy1*cfactory*ubfactory;
    return (x0, y0)
end


"""
`ctchildwidth(width0, contextdim::NTuple{4,<:Real};UnitBox::NTuple{4,<:Real}=(0,0,1,1))` convert the width in `c0` to the length it should be in `c1` that the line: 
```
c0 = context();
c1 = context(contextdim...;units=UnitBox(0,0,2,2));
width1=ctchildwidth(width0, contextdim;UnitBox=(0,0,2,2));
compose(c0, (c1, line([(0,0),(width1,0)])) )
```
has the length looks visually the same as:
```
compose(c0, line([(0,0),(width0,0)]) )
```
"""
function ctchildwidth(width0, contextdim::NTuple{4,<:Real};UnitBox::NTuple{4,<:Real}=(0,0,1,1))
	# width0/contextdim[3] = width1/UnitBox[3]
	return width0*UnitBox[3]/contextdim[3] # width1
end

"""
`height1 = ctchildheight(height0, contextdim::NTuple{4,<:Real};UnitBox::NTuple{4,<:Real}=(0,0,1,1))` works the same as `ctchildwidth()` but rescale in y direction. See `ctchildwidth`'s documentation.
"""
function ctchildheight(height0, contextdim::NTuple{4,<:Real};UnitBox::NTuple{4,<:Real}=(0,0,1,1))
	# height0/contextdim[4] = height1/UnitBox[4]
	return height0*UnitBox[4]/contextdim[4] # height1
end


dfthw = 0.015; # default head width
dfthh = 0.025; # default head height
"""
`myarrow(startpoint, arrangle, arrlength; headwidth=$dfthw, headheight=$dfthh) |> polygon`
"""
function myarrow(startpoint, arrangle, arrlength; headwidth=dfthw, headheight=dfthh)
	rot(θ,point) = (point[1]*cos(θ) - point[2]*sin(θ), point[1]*sin(θ) + point[2]*cos(θ));
	xo,yo = (0.0,0.0);
	head_x =xo + arrlength;
	headpoint = (head_x, yo);
	sidepoint_a = headpoint.+(-headheight,yo-headwidth/2);
	sidepoint_b = headpoint.+(-headheight,yo+headwidth/2);
	function lim_x(sidepoint_a)
		sidepoint_a = maximum.(([sidepoint_a[1], xo], [sidepoint_a[2]]))
	end
	sidepoint_a = lim_x(sidepoint_a);
	sidepoint_b = lim_x(sidepoint_b);

	eq_triangle = [sidepoint_a,
				   sidepoint_b,
				   headpoint]
				   
	tailwidth = headwidth/5;
	tail_a = (xo, yo+tailwidth);
	tail_b = (xo, yo-tailwidth);
	tail_c = (sidepoint_b[1], yo-tailwidth); # sidepoint_a[1] should equal sidepoint_b[1]
	tail_d = (sidepoint_a[1], yo+tailwidth);
	
	pts = rot.([arrangle], [tail_a, tail_b, tail_c, sidepoint_a, headpoint, sidepoint_b, tail_d]);
	xs = [pt[1] for pt in pts] .+ startpoint[1];
	ys = [pt[2] for pt in pts] .+ startpoint[2];

	return tuple.(xs, ys)
end

"""
`myarrow(startpoint, arrangle, arrlength, contextdim::NTuple{4,<:Real}; UnitBox::NTuple{4,<:Real}=(0,0,1,1))` is the same as `myarrow(startpoint, arrangle, arrlength; headwidth=$dfthw, headheight=$dfthh)` but the arrows `headwidth` and `headheight` will be converted to make sure their size is consistent.
"""
function myarrow(startpoint, arrangle, arrlength, contextdim::NTuple{4,<:Real}; UnitBox::NTuple{4,<:Real}=(0,0,1,1), headwidth=dfthw, headheight=dfthh)
	hh = ctchildwidth(headheight, contextdim; UnitBox=UnitBox); # headheight is "along x axis" at zero degree, so we have to use `ctchildwidth` to covert.
	hw = ctchildheight(headwidth, contextdim; UnitBox=UnitBox);
	return myarrow(startpoint, arrangle, arrlength; headwidth=hw, headheight=hh)
end




"""
`composelabels(xstr, ystr, contextdim)` add x and y labels on the parent frame of `contextdim`.

```julia
composelabels(labels::Vector{<:AbstractString}, contextdim::NTuple{4,<:Real}; labelloc::Vector{Symbol}=[:bottom,:left], labeldir::Vector{Symbol}=[:h,:h], labelcolor=("black","black"))
```
- supported `labelloc`: `:bottom`,`:top`,`:left`,`:right`.
- `labeldir=:h` means the label is horizontally placed; `labeldir=:h`, vertically placed.

# Example:
```julia
contextdim = (0.1,0.4,0.8,0.55); # the position of `cplot1`
cplot1 = (context(contextdim..., units=UnitBox(UB1...)), 
blablabla...); # a plot perhaps

cplot1withlabels = (context(), composelabels(["time","velocity"],contextdim;labelloc=[:left,:top], labeldir=[:v,:h])..., cplot1);
compose(context(), cplot1withlabels)
```
"""
function composelabels(labels::Vector{<:AbstractString}, contextdim::NTuple{4,<:Real}; labelloc::Vector{Symbol}=[:bottom,:left], labeldir::Vector{Symbol}=[:h,:h], labelcolor=("black","black"))
    labh = 0.03; # labelheight
    textpos = (0.5,0.5); # of created label context
    (pad1x, pad1y, width1, height1) = contextdim;

    lenl = length(labels);
    
    if length(labelloc) != lenl || length(labeldir) != lenl
        error("`labelloc`/`labeldir` has to be the same length as `labels` for specifying labels' location/orientation.");
    end
     
    contexts = [];
    for i = 1:lenl
        textrot = ();
        textalign = ();
        # txtpt = (1.0,0.5);
        # (pad1x, pad1y, width1, height1) = contextdim;
        # labh = 0.03;
        # 
        # leftlabel = (a1,pad1y,pad1x-a1,height1);
        # cplot1a = (context(), (context(leftlabel...),Compose.text(txtpt...,"hello world",hright,vcenter,Rotation(-1/2*pi,0.5,0.5)) ,(context(), rectangle(), stroke("pink"),fillopacity(0.3)))
        # ,cplot1);
        
        if labelloc[i] == :left
            a1 = maximum([0.0, pad1x-labh]);
            contextdim_txt = (a1,pad1y,pad1x-a1,height1);
            textpos = (0.9,0.5);
            textalign= (hright, vcenter);
        end
        
        if labelloc[i] == :bottom
            a1 = minimum([1.0-pad1y-height1, labh]);
            contextdim_txt = (pad1x, pad1y+height1, width1, a1);
            textpos = (0.5, 0.1);
            textalign= (hcenter,vtop);
        end
        
        if labelloc[i] == :top
            a1 = maximum([0.0, pad1y-labh]);
            contextdim_txt = (pad1x, a1, width1, pad1y-a1);
            textpos = (0.5,0.9);
            textalign= (hcenter,vbottom);
        end
        
        if labelloc[i] == :right
            a1 = minimum([1.0-pad1x-width, labh]);
            contextdim_txt = (pad1x+width1, pad1y, a1, height1);
            textpos = (0.1, 0.5);
            textalign= (hleft,vcenter);
        end
        
        if labeldir[i] == :v
            textrot = (Rotation(-pi/2,0.5,0.5),);
            textpos = (0.5, 0.5);
            textalign= (hcenter,vcenter);
        end
        # convert dictionary to named tuple
        # TODO: write this technique to Notes
        # opts = NamedTuple{Tuple(keys(contextopt_d))}(values(contextopt_d));
        
        push!(contexts, 
              (context(contextdim_txt...), 
               Compose.text(textpos..., labels[i], textalign..., textrot...),fill(labelcolor[i])),
        );
        
    end
    return contexts
end




"""
`pos2points(xstart, ystart, width, height)` convert the position to a vector of points `[(xstart, ystart), (xstart, ystart+height), (xstart+width, ystart+height), (xstart+width,ystart)]`.
"""
function pos2points(xstart, ystart, width, height)
    return [(xstart, ystart), (xstart, ystart+height), (xstart+width, ystart+height), (xstart+width,ystart)]
end

function pos2points(pos::NTuple{4,<:Real})
    pos2points(pos...);
end

"""
`pointshift(point::NTuple{2,<:Real}, shift2::NTuple{2,<:Real})` returns `(point[1]+shift2[1], point[2]+shift2[2])`.
"""
function pointshift(point::NTuple{2,<:Real}, shift2::NTuple{2,<:Real})
    return (point[1]+shift2[1], point[2]+shift2[2])
end