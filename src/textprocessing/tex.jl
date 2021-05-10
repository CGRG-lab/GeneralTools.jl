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
function removecomment!(tex)
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
removesection!(tex, sectionname)
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

"""
function removesection!(tex, sectionname)

    begins = findall(.~isnothing.(match.(Regex("^(\\\\begin{$(sectionname)[\\*]*})"), tex)));
    ends = findall(.~isnothing.(match.(Regex("^(\\\\end{$(sectionname)[\\*]*})"), tex)));
    
    id2rm = Int64[];
    for (id0, id1) in (begins .=> ends)
        id2rm = vcat(id2rm, collect(id0:id1));
    end
    
    deleteat!(tex, id2rm);
    return nothing
end