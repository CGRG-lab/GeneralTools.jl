# Tools for DataFrame Processing

defaultchkfn = (ismissing, isnothing, isnan);

"""
`filtern` works based on `filter` automatically drop rows where the corresponding specific column `col1` contains `NaN`, `missing` or `nothing`. 

`filtern(col1, df)` is the shorthand of `filter(cols => fun, df::AbstractDataFrame)` where `fun` is for examing whether the column contains `NaN`, `missing` or `nothing`.
"""
function filtern!(col, df; chkfun=defaultchkfn)
    # see this thread: https://stackoverflow.com/questions/62789334/how-to-remove-drop-rows-of-nothing-and-nan-in-julia-dataframe
    return filter!(col => c1 -> !any(f -> f(c1), chkfun), df)
end

"""
`filtern(col1, col2, df)` automatically drop rows where either of `col1` and `col2`  contains `NaN`, `missing` or `nothing`. 
"""
function filtern!(col1, col2, df; chkfun=defaultchkfn)
    return filter!([col1, col2] => (c1, c2) -> !any(f -> f(c1) || f(c2), chkfun), df)
end

"""
`(df_seg, col_indicator) = forsegplot(df, [:col1, :col2])` returns `df_seg` (a copy of dataframe `df`) and the column indicators (a named tuple), for `Gadfly.plot(df_seg, Geom.segment; col_indicator...)` plot in Gadfly. 
Basically, 
```julia
(df_seg, col_indicator) = forsegplot(df, [:col1, :col2]);
Gadfly.plot(df_seg, Geom.segment; col_indicator...);
```

is equivalently


```julia 
x = df[:col1];
y = df[:col2];
df_seg = DataFrame(x0=x[1:end-1], x1=x[2:end], # segment's starts
                   y0=y[1:end-1], y1=y[2:end], # segment's ends

Gadfly.plot(df_seg, x=:x0,y=:y0,xend=:x1, yend=:y1, Geom.segment)
```


`forsegplot(df, [:col1, :col2, :col3])` does the a similar job but returns a dataframe with columns named `:x0`, `:y0`, `:z0`; higher dimension is not supported yet.
"""
function forsegplot(df::DataFrame, cols::Vector{<:Union{Symbol, String}}) # 
    names0 = [:x0, :y0, :z0];
    names1 = [:x1, :y1, :z1];

    col_indicator = (x=:x0, y=:y0, xend=:x1, yend=:y1); 
    if length(cols) > 2
        col_indicator = merge(col_indicator, (z=:z0, zend=:z1));
    end
    

    lenc = length(cols);
    names0 = names0[1:lenc];
    names1 = names1[1:lenc];
    
    values0 = [];
    values1 = [];
    
    for name in cols
        xi = df[!,name];
        push!(values0, xi[1:end-1]);
        push!(values1, xi[2:end]);
    end
    
    cb(v1, v2) = [permutedims(hcat(v1, v2))...]; # making a n by 2 matrix using v1 and v2, and transpose it and release every element that we can have something like :x0, :x1, :y0, :y1...
    
    allnames = (cb(names0, names1)...,); # must be a tuple for NamedTuple construction
    allvalues = cb(values0, values1);
    nt = NamedTuple{allnames}(allvalues);

    df_seg = DataFrame(nt);
        
    return df_seg, col_indicator

end