# module tempmod # for redefining structure easily while developing
	mutable struct Tex
		eachline::Vector{<:AbstractString}
		istarget::Vector{Bool} # Default is all true. See outer constructor.
		targetrange::Vector{UnitRange{Int64}}
		
	end
	function Tex(eachline::Vector{<:AbstractString})
	targetrange = map(x -> 1:length(x), eachline);
	istarget =  .!isempty.(targetrange); # 1:0 is empty. Which means "" is not the target.
	
	Tex(eachline,istarget,targetrange);
	# require more complex function to also auto generate correct targetrange?
	end
	
# end


"""
`refresh!(TEX::Tex)` refresh `TEX.istarget` according to `TEX.targetrange`.
This could be useless.
"""
function refresh!(TEX0::Tex)
	TEX0.istarget .= .!isempty.(TEX0.targetrange); # 1:0 is empty. Which means "" is not the target.
end

"""
```
texpath1 = joinpath(pwd(),"main1.tex")
texpath0 = joinpath(pwd(),"main0.tex")
pushback(texpath0, texpath1);
```
Push the contents of `tex1` back into the original `tex0`, replacing the original contents while preserving comments and begin-ends sections in `tex0`. 
These contents are those not belong to
- section (e.g. `\\section{}`, `\\figure{}`, etc.)
- comments (e.g. `% hello I'm comment`)
"""
function pushback(texpath0, texpath1)
	# should be equivalent to `tex0 = open(x->readlines(x), texpath0)`;
	tex0 = open(texpath0) do file
		readlines(file);
	end
	tex1 = open(texpath1) do file
		readlines(file);
	end
	
	TEX0 = Tex(tex0);
	TEX1 = Tex(tex1);
	
	# criteria:
	# before \begin{document}, all lines should be neglected
	# all sections (e.g. \begin{xxx}...\end{xxx}) should be ignored except
	# all lines begin with `\` despite `\cite`
	
	# Expression for the criteria that defines our target sentences.
	expr1 = r"^([A-Za-z\[\]\(\)\$\"`]|[1-9]|,|;|\\cite|\s+\w)[^%]*(?=%?)"; 
	# We target lines who start with:
	# 	[A-Za-z\[\]\(\)\$] denotes
	# 		- normal characters (A-Z and a-z)
	# 		- parenthesis "(", ")", "[", "]"
	# 		- variable or inline equation, e.g. "$F = ma$ the Newton's 2nd law blablabla"
	# and
	# 		- inline citation may be just at the first of a line ("\cite{blablabla2021}")
	# 		- anything starts with one or more white space and words (\s+\w)
	# and anything that is not a comment "[^%]*"
	# that may ended with one or no comment "(?=%?)".
	
	# https://regex101.com/r/x0HEer/1
	pushback_rm!(expr1, TEX0);
	pushback_rm!(expr1, TEX1);
	
	if sum(TEX0.istarget) != sum(TEX1.istarget)
		outputpath0_a = pushback_genfile1(texpath0, TEX0);
		outputpath0_b = pushback_genfile1(texpath1, TEX1);
		openit(dirname(outputpath0_b));
		fname1_b = basename(outputpath0_b);
		fname1_a = basename(outputpath0_a);
		fname0_a = basename(texpath0);
		fname0_b = basename(texpath1);
		
		error("""Inconsistent in the number of lines. Please edit on `$fname1_b` to make the lines consistent with `$fname1_a` (e.g. use vscode compare), where adding dummy new lines might be necessary (e.g. valid: "(CHECKPOINT: nothing here)"; invalid: "\\n"). Then, run the same function but with modified later file (e.g. `pushback("$(fname0_a)","$(fname1_b)")`). After that, it is suggested to compare $fname1_b with the original $fname0_b""");
	end
	
	newstr = TEX1.eachline[TEX1.istarget];
	for (i, TF) in enumerate(TEX0.istarget)
		if TF
			str0v = split(TEX0.eachline[i],""); # split into vector of chars
			rnga = TEX0.targetrange[i]; # range of non-comment
			# str0a = join(str0v[rnga]); # old content without comment
			str0v[rnga] .= ""; # remove old content but reserve comment.
			str0c = join(str0v); # comment only
			str1a = popfirst!(newstr); # new content
			TEX0.eachline[i] = str1a*str0c; # finish replacing old content by new one despite old comment.
		end
	end
	outputpath0_b = pushback_genfile2(texpath0, TEX0);
	fnm0 = basename(texpath0);
	fnm1 = basename(texpath1);
	fnm2 = basename(outputpath0_b);
	println("Content successfully combined. Since a few specific types of contents won't be successfully pushed back (e.g. changes in title and subtitle), please check the results by: ");
	println("1. Comaring $fnm2 with $fnm1 (old) to check if contents were correctly inserted. (There shouldn't be any differences except comments and begin-end sections)")
	println("2. Comparing $fnm2 with $fnm0 for english editing viewing.");
	openit(dirname(outputpath0_b));
end	
	
function pushback_genfile1(texpath0,TEX0::Tex)
		fname0 = basename(texpath0);
		strvec0 = getext(fname0);
		strvec0[1] = strvec0[1]*"_contentonly";
		fname0_a = join(strvec0)
		dir_0 = dirname(texpath0);
		outputpath0_b = joinpath(dir_0,fname0_a);
		open(outputpath0_b,"w") do io
			for (i, TF) in enumerate(TEX0.istarget)
				if TF
					range_i = TEX0.targetrange[i];
					println(io, TEX0.eachline[i][range_i]);
				end
			end
		end
		return outputpath0_b
end

function pushback_genfile2(texpath0,TEX0::Tex)
		fname0 = basename(texpath0);
		strvec0 = getext(fname0);
		strvec0[1] = strvec0[1]*"_combined";
		fname0_a = join(strvec0)
		dir_0 = dirname(texpath0);
		outputpath0_b = joinpath(dir_0,fname0_a);
		open(outputpath0_b,"w") do io
			for i in eachindex(TEX0.eachline)
				println(io, TEX0.eachline[i]);
			end
		end
		return outputpath0_b
end

function pushback_rm!(expr1::Regex, TEX0::Tex)
	for (i,mt) in enumerate(match.(expr1, TEX0.eachline))
		if !isnothing(mt)
			TEX0.targetrange[i] = mt.offset:length(mt.match);
			TEX0.istarget[i] = true; # this could be unnecessary
		else # nothing matched
			TEX0.targetrange[i] = 1:0;
			TEX0.istarget[i] = false;
		end
	end
	removesection!(TEX0, "figure");
	removesection!(TEX0, "table");
	removesection!(TEX0, "equation");
end

"""
removecomment!(tex)
- Remove all comments (text after the `%`) in the `.tex` file.
- `tex` should be an 1d array of strings, with each element the texts of a line.
- Please check again the result (e.g. check with git compare).

# Example:
```
tex = open(inputfpath_tex) do file
	readlines(file);
end 
removecomment!(tex)
```
"""
function removecomment!(tex::Vector{String})
	ind2rm = Int64[];
	for i = 1:length(tex)
		onelncmt = match( r"^%",tex[i]);# oneline comment
		if isnothing(onelncmt)
			m = match(r"%", tex[i])
			if ~isnothing(m)
				newstr = tex[i][1:m.offset-1]
				tex[i] = newstr;
			end
		else # it begins with "%" therefore the whole line should be removed
			push!(ind2rm, i);
		end
	end 
	deleteat!(tex, ind2rm);
	return nothing
end





"""
removesection!(tex::Vector{<:AbstractString}, sectionname)
- Remove section(s) in the `.tex` file.
- In which, every section should begin with the first line being `\\begin{sectionname[*]}` and the last line `\\end{sectionname[*]}` (where the asterisk denotes the width of the section (e.g. table, figure) is two column width).

For example, `removesection!(tex, "figure")` remove both

```
\\begin{figure}
<Figure here>
\\end{figure}
```

and

```
\\begin{figure*}
<Figure here>
\\end{figure*}
```
# WARNING:
The `\\begin...` or `\\end...` must be at the first of a line. For example, match missed when ` \\begin...`.
"""
function removesection!(tex::Vector{<:AbstractString}, sectionname)
	id2rm = removesection_secrange(tex,sectionname);
    deleteat!(tex, id2rm);
    return nothing
end

"""
removesection!(TEX::Tex, sectionname)
Modify the `Tex` object where the field `istarget` is set to false for the corresponding section specified by `sectionname`. This function only change the indicators, not any content will be removed.
"""
function removesection!(TEX::Tex, sectionname)
	tex = TEX.eachline;
	id2rm = removesection_secrange(tex,sectionname);
	for i in id2rm
		TEX.targetrange[i] = 1:0; # don't use broadcast
		TEX.istarget[i] = false;
	end
    return nothing
end


function removesection_secrange(tex,sectionname)
    begins = findall(.~isnothing.(match.(Regex("^(\\\\begin{$(sectionname)[\\*]*})"), tex)));
    ends = findall(.~isnothing.(match.(Regex("^(\\\\end{$(sectionname)[\\*]*})"), tex)));
    id2rm = Int64[];
    for (id0, id1) in (begins .=> ends)
        id2rm = vcat(id2rm, collect(id0:id1));
    end
	return id2rm
end






