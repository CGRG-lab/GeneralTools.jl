# using Compose
# stroke = Compose.stroke;
# rectangle = Compose.rectangle;
# circle = Compose.circle;
# UB = (0,0,1,1);
# contextdim = (0.5,0.5,0.5,0.5);
# (x1, y1) = (0.5,0.0);
# c0 = context();
# c1 = context(contextdim...;units=UnitBox(UB...));
# (x0,y0) = ctparent((x1,y1), contextdim;UnitBox=UB)
# compose(c0, 
#     (c0, circle(x0,y0,0.09), stroke("cyan")),
#     (c1, circle(x1,y1,0.1), stroke("red"))
# 	, fill(nothing)
#     )
	   
@testset "Check if `ctparent` works fine:" begin 

	UB = (0,0,2,2);
	contextdim = (0.0,0.5,0.5,0.5);
	(x1, y1) = (1,1);
	@test ctparent((x1,y1), contextdim;UnitBox=UB) == (0.25, 0.75)
	
	UB = (0,0,3,2);
	contextdim = (0.0,0.2,0.4,0.1);
	(x1, y1) = (1.5,1.0);
	@test ctparent((x1,y1), contextdim;UnitBox=UB) == (0.2, 0.25)
	
	UB = (0,0,1,1);
	contextdim = (0.5,0.5,0.5,0.5);
	(x1, y1) = (0.5,0.0);
	@test ctparent((x1,y1), contextdim;UnitBox=UB) == (0.75, 0.5)
	# @test ctparent((x1,y1), contextdim;UnitBox=UB) == 
end