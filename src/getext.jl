"""
`getext(pathname)` split the input name into the [name,".",extension] array.
# Example:
```
	pathsplit = getext("inputfpath\\file.ext")
    pathsplit[1] = pathsplit[1]*"_copy";
	outputpath = join(pathsplit); # which returns "inputfpath\\file_copy.ext"
```
"""
function getext(pathname)
	dotpos = findall(isequal('.'),pathname);
	str_ext = pathname[(dotpos[end]+1):length(pathname)];
	str_beforedot = pathname[1:(dotpos[end]-1)];
	return [str_beforedot,".",str_ext]
end