"""
- cdfE calculated empirical cumulative distribution function F(y<=yi)
- To get the CCDF of Y (complementary cumulative distribution function): 
	- ccdf(Y) = 1- cdf(Y);
Example:
    [cdfY,y] = cdfE(Y,nbins); % nbins: number of bins (i.e. number of y points)
    [cdfY,y] = cdfE(Y,y); % y is the mid-points of the edges of bins. % This is expected to be the fastest.
                                               % Noted that the 'EdgeScale' has no effect on output results since y is specified.
    [cdfY,y] = cdfE(Y);
"""	
function cdfE(Y; nedges::Int=100)
	edges(l,r,pt) = collect(range(l,r,length = pt));
	y = edges(minimum(Y), maximum(Y), nedges);		
	cdfY = cdfE_core(y, Y, nedges);
	(y, cdfY);
end

function cdfE(Y, y::Vector; edgescale=:linear)
	nedges = length(y);
	cdfY = cdfE_core(y, Y, nedges)
end

function cdfE_core(y, Y, nedges)
	Y = [Y...];
	cdfY = fill(NaN,nedges)
	invlenY = 1/length(Y);
	for i = 1:nedges
		cdfY[i] = sum(Y .<= y[i])*invlenY;
	end
	cdfY
end