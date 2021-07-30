"""
`getdoc(filepath::String; first_head=0)`
read the function descriptions and return a `Markdown.parse`d object.
Now it supports matlab's `.m` function only. 
TODO: add julia support.

# Example
- `y = getdoc("..\\..\\src\\statind.m")` get all the comments (starts with `% ` eachline) `before function statind(...)`
- `y = getdoc("..\\..\\src\\statind.m", first_head=3)` get all the comments before function section and rearrange all the heading levels based on forcing the first heading level to be 3. That is, take the first heading to be `#` for example, `#` becomes `###` and `##` becomes `####`
"""
function getdoc(filepath::String; first_head=0)
	
	
	s = open(filepath) do file
		readlines(file);
		end
	if getext(filepath)[end] == "m" # if it is the matlab file
		funbegin = findfirst(occursin.(r"^function\s",s));
		# find the line where function begin
		if funbegin == 1
			return "No documentation for $filepath"
		end
		
		doc = s[1:funbegin-1];
		x = join(lang_matlab(doc,first_head = first_head));
		y = Markdown.parse(x); # or @eval @md_str $x is the same.
	else
		y = Markdown.parse("<unsupported language>");
	end
	
	return y
end

function lang_matlab(doc; first_head=0)
	# for Weave.jl, both default or pandoc2html output, mulitiple empty lines == one and results in a linebreak, and linebreak (but no empty line in between) is ignored. So I add linebreaks very generously here.
	br = "\n"; # linebreak
	# delete "%" in the beginning of the line.
	doc2 = replace.(doc, r"^%+\s?" => "");

	if first_head != 0 # reformat markdown head levels
		lenhashtags0 = match(r"^#+",doc2[1]).match |> length;
		adjust_diff = first_head - lenhashtags0;
		
		ishead = occursin.(r"^#+",doc2[1:end]);
		targetid = findall(ishead);
		for i in targetid
			lenhashtags_i = match.(r"^#+",doc2[i]).match |> length;
			new_head = "#"^(lenhashtags_i+adjust_diff);
			doc2[i] = replace(doc2[i], r"^#+" => new_head);
		end
	end
	
	for (i,val) in enumerate(doc2)
		doc2[i] = val*br; # add linebreak at the end of every line.
	end
	
	# codefence = findall(occursin.(r"^(```)",doc2));
	# codestart = codefence[1:2:end];
	# codeend = codefence[2:2:end];
	
	# numinserted = 0;

	# for id in codefence
	# 	id = id + numinserted;
	# 	# if iseven(numinserted)
	# 	# 	insertat = id; # insert before
	# 	# else
	# 	# 	insertat = id+1;  # insert after
	# 	# end
	# 	insert!(doc2, id, br); # add linebreak before
	# 	insert!(doc2, id+2, br); # add linebreak after
	# 	numinserted = numinserted + 2;
	# end
	return doc2
end