using Dates
using CSV
DateTimeArray = Union{Array{Date,1}, Array{DateTime,1}};
function eventFilter(catalog::String, dt::DateTimeArray)
"""
filter the catalog by date/datetime
Example:
catalog = "C:\\Google THW\\1Programming\\MATLAB\\CWB_precursor\\GM_station_info\\CWBcatalog_M3_2006to2019.csv"
catalog = "D:\\GoogleDrive\\1Programming\\MATLAB\\CWB_precursor\\GM_station_info\\CWBcatalog_M3_2006to2019.csv"
dt = [Date(2012,1,2), Date(2008,5,2)];
catalog_f = eventFilter(catalog::String, dt::DateTimeArray)
""" 
    timeFormat = DateFormat("y/m/d HH:SS");
    sort!(dt);
    df = CSV.read(catalog);
    df.DateTime = DateTime.(df.time,timeFormat);
    # sort!(df,:DateTime); # sort according to the DateTime column
    desired_ind = dt[1] .< df.DateTime .< dt[end]
    df2 = df[desired_ind,:];
    return df2
end
function eventFilter(catalog::String, dt::Array{String,1})
    timeFormat = DateFormat("yyyymmdd");
    dt = Date.(dt,timeFormat);
    df2 = eventFilter(catalog,dt);
    return df2
end
