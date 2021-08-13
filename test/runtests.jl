using Test
using GeneralTools
	
println("Running tests:")

(testfiles, allnames) = targetlist(r"^(?!runtests).*(\.jl)$", "./");
# pwd() here should be "./test/"
for f in testfiles
	include(f);
end


