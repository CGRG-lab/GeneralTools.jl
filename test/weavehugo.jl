expr_removebackslash = GeneralTools.expr_removebackslash;

@testset "Check if regular expression pattern `$expr_removebackslash` works fine:" begin 
	@test replace("\\\\using_gadfly_10_1.png", expr_removebackslash => "") == "using_gadfly_10_1.png"
	@test replace("\\blas\\(0)cu2\\using_gadfly_10_1.png", expr_removebackslash => "") == "blas\\(0)cu2\\using_gadfly_10_1.png"
	@test replace("/using_gadfly\\asdf_fd/_10_1.png", expr_removebackslash => "") == "using_gadfly\\asdf_fd/_10_1.png"
	@test replace("/using_gadfly/asdf_fd/_10_1.png", expr_removebackslash => "") == "using_gadfly/asdf_fd/_10_1.png"
	@test replace("using_gadfly/asdf_fd/_10_1.png", expr_removebackslash => "") == "using_gadfly/asdf_fd/_10_1.png"
	@test replace("using_gadfly_10_1.png", expr_removebackslash => "") == "using_gadfly_10_1.png"
end