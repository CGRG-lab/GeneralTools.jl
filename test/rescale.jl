@testset "Test rescale" begin
	for _ in 1:100
		vec0 = sort(randn(rand(2:500)));
		vec2 = rand(1:100)*randn(2) |> sort
		vec1 = rescale(vec0, vec2)
		diffvec1 = diff(vec1);
		a = diff(vec0)./diffvec1;
		meana = sum(a)/length(a);
		@test all(diffvec1 .>= 0) # increaments have to be all positive
		@test isapprox.(a .- meana, 0; atol=meana*1e-6) |> all
	end
	
end