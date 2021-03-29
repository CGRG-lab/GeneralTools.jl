function openit(path::AbstractString)
    if !ispath(path)
        @warn("You have entered an invalid file system entity.");
        return nothing
    end

    if Sys.iswindows()
        # if isfile(path)
        #     run(`cmd /c start $path`, wait=false);
        # else
            run(`cmd /c start %windir%\\explorer.exe $path`, wait=false);
        # end
    elseif Sys.islinux()
        run(xdg-open $path, wait=false);
    else
        @warn("Couldn't open $path");
    end
    return nothing
end
