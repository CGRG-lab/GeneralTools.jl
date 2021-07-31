using Markdown

main_folder="juliamarkdown";

notice = Markdown.parse("""
1. Please apply the following first:
```
using Weave, GeneralTools
```

2. You can alternatively specify the weave option in the front matter. For example, add the following to the front matter (header) of the your julia-markdown file:
```
weave_options: 
  fig_path: ./
  hugo:
    out_path: ./_index.md
  md2pdf:
    out_path : ../pdf
  md2html:
    out_path : ./_index.html
```
Notice that in this way the path is relative to the path of julia markdown, not the current directory. That is, for that in the front matter we have `out_path: ./_index.md` and doing `weave("$main_folder/your_file.md")`, the result is the same as `weave(...; out_path="$main_folder/_index.md")`

""");


"""
`cp2content` copy the generated hugo markdown file to your site's `content`.
# Example 
```
lazyhugo();
cp2content("D:/GoogleDrive/Sites/learning-notes/content/en/my-project/MagTIP");
```
, where `main_folder="$main_folder"` is defined by default.

# Notice
$notice
"""
function cp2content(dst; force=true, main_folder=main_folder)

    allfiles = readdir(main_folder, join=true);
    bnames = getext.(allfiles); # base names
    isfig = map(x -> occursin(r"(png|jpe?g|svg|eps|gif|apng)",x[end]), bnames);
    isindex = occursin.(r"_?index\.md", basename.(allfiles));
    
    figures = allfiles[isfig];
    theindex = allfiles[isindex];
    
    if length(theindex) != 1 
        openit(joinpath(pwd(),main_folder));
        error("No or more than one `index.md` file(s). `weave` first and check the opened folder!");
    end
    
    src = [figures;theindex];	
    dsts = joinpath.(dst,basename.(src));
    cp.(src, dsts; force=force);
    
    println("Files copied to $dst except:");
    println.(allfiles[.!(isfig .| isindex)]);
end

"""
`lazyhugo(filename)` is equivalent to `weave("$main_folder/\$filename";informat="markdown", doctype="hugo", out_path="$main_folder/_index.md",  fig_path="./")`. Simply `lazyhugo()` automatically search for the markdown file not named as "_index.md" or "index.md"; if multiple or no markdown files were found, an error will be raised.

# Notice
$notice

"""
function lazyhugo(c...)
    if isempty(c)
        allfiles = readdir(main_folder);
        id = occursin.(r"(?<!index)\.md",allfiles);
        filenames = allfiles[id];
        if length(filenames) != 1
            error("No or multiple markdown files exists. Please explicitily specify the target file you want to weave. For example, `lazyhugo(Doc.md)`");
        end
        filename = filenames[1];
        println("`$filename` is going to be weaved:");
    else
        filename = c[1];
    end
    weave("$main_folder/$filename";informat="markdown", doctype="hugo", out_path="$main_folder/_index.md", fig_path="./");
end







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


"""
`defolder(dir)`
Delete all empty folders left everytime we use the `weave(...)`.
"""
function defolder(dir::AbstractString="output")
  flist = readdir(joinpath(pwd(),dir), join=true);
  dirtrue = isdir.(flist);
  fmtmatched = .!isnothing.(match.(r"jl_[A-Za-z0-9]{6}",flist));
  rm.(flist[dirtrue .& fmtmatched]);
end