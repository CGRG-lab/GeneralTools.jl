
"""
`targetlist(targetexpr::Regex, dir2walk::AbstractString)` returns `targetpaths, allfiles`
"""
function targetlist(targetexpr::Regex, dir2walk::AbstractString)
    # targetexpr = r"(\.jl)$";
    fulllist = String[];
    for (root, folders, files) in walkdir(dir2walk)
        for file in files
            push!(fulllist, joinpath(root, file));
        end
    end
    allfiles = basename.(fulllist);
    targetid = occursin.(targetexpr, allfiles);
    
    targetpaths = fulllist[targetid];
    return targetpaths, allfiles
end