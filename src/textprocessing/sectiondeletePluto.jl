
# sec2delete = "# ╟─2b4a8e35-7cef-4eed-bad2-29b9290756b6
# # ╟─e488cf57-0948-48a8-9caf-c18405ecfdae
# # ╟─19e15dda-281e-4e3d-82e7-9b1ae3ae2fa1
# # ╠═665e56b1-d063-4d58-9ff4-61b9ef914641
# # ╠═3bcd446d-652c-4b4c-ac37-7ad70009a831
# # ╟─0febdbc8-3829-44e2-adfc-7b4656549a5b
# # ╠═623c3306-6fbb-4500-8675-a6c66dfac2aa
# # ╠═9fb0ddcd-ee66-42fa-ac14-5ea6db4c5b14
# # ╠═dad2eee8-166a-46f1-8f0b-1abf0a490eda
# # ╟─fdb9b72c-b107-42e1-844e-5ee33f626a13
# # ╠═716b3c84-d02b-4ea0-81d9-d679ceb53503
# # ╟─43e800b7-ef12-44e5-923c-e42323a92872
# # ╠═8d6d11f4-4329-4a7b-ae0e-5de7db67f88c
# # ╟─aee72572-eddb-4a74-810b-5cbdac7325dc
# # ╠═6cb8decc-d3ad-408f-96fa-2c667cf73c38
# # ╟─4e1538f1-a134-4cf0-913c-7f5e9f2864ab
# # ╠═71a4f0ca-f6db-486f-af45-7914ef71b90d
# # ╠═48c140c1-0e29-4dae-bcaf-d816bebcbdb7
# # ╟─e002ef9d-c03b-498c-b830-796f6bf4a5e3
# # ╟─dfd9a282-1b1d-428c-b306-8a44edbf0c3e
# # ╠═037f673c-5a05-4e90-84ee-f10d4769e5ca
# # ╠═378c2188-7cb3-44cd-87d6-7d35a2eb594c"
function sectiondeletePluto(fpath::String,newpath::String, sec2delete)
lines = open(fpath) do file
	readlines(file);
end

id2 = lines .== "# ╔═╡ Cell order:";
lenid2 = findall(id2);
lnco = length(lenid2)==1 ? lenid2[1] : error("Something wrong");

part1 = lines[1:lnco-1];
part2 = lines[lnco:end];
key1s = get_keys(part1, "# ╔═╡ ");
key2s = get_keys(part2, "(# ╠═|# ╟─)");

sort(key1s) == sort(key2s) ? nothing : error("Keys not matched.")

id0s = findall(occursin.(r"# ╔═╡ ",part1));
id1s = findall(occursin.(r"# ╔═╡ ",part1)) .- 1;
popfirst!(id1s);
push!(id1s,lnco-1);
ids1 = hcat(id0s, id1s);
ids2 = findall(occursin.(r"(# ╠═|# ╟─)",part2));


keys2delete = collect(eachmatch(Regex("\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w{6}"),sec2delete))
keys2delete = [mt.match for mt in keys2delete];

length(key1s) == length(id0s) ? nothing : error("Section keys and section line numbers mismatch.");

delete_lines!(key1s, part1, keys2delete,ids1);
delete_lines!(key2s, part2, keys2delete, ids2);

open(newpath,"w") do io
	for line in vcat(part1, part2)
		println(io, line);
	end
end

end

function delete_lines!(key1s, part1, keys2delete, ids)
	srng2delete_pt1 = [];
	for keyd in keys2delete
		push!(srng2delete_pt1, ids[occursin.(Regex(keyd), key1s), :]);
	end


	deleteat!(part1, vcat(collect.(map(x -> x[1]:x[end], srng2delete_pt1))...));
end

function get_keys(partn,prefix)
	match1 = match.(Regex("(?<=$prefix)\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w{6}"),partn);
	keys = [];
	for mt in match1
		!isnothing(mt) ? push!(keys,mt.match) : continue
	end
	return keys
end