-module(geotools).

-export([
		 dist_simple/2,		%calc. distance (args in degrees)
		 sphere_direct/3,	%solve direct problem (args in degrees)
		 sphere_directr/3,	%solve direct problem (args in radians)
		 sphere_inverse/2,	%solve inverse problem (args in degrees)
		 sphere_inverser/2,	%solve inverse problem (args in radians)
		 azimuth/2,			%calc. azimuth (args in degrees)
		 dist/2				%calc. distance (args in degrees)
		]).

dist_simple({Lng1, Lat1}, {Lng2, Lat2}) ->
	Deg2rad = fun(Deg) -> math:pi()*Deg/180 end,
	[RLng1, RLat1, RLng2, RLat2] = [Deg2rad(Deg) || Deg <- [Lng1, Lat1, Lng2, Lat2]],

	DLon = RLng2 - RLng1,
	DLat = RLat2 - RLat1,

	A = 
	math:pow(math:sin(DLat/2), 2) + 
	math:cos(RLat1) * 
	math:cos(RLat2) * 
	math:pow(math:sin(DLon/2), 2),

	C = 2 * math:asin(math:sqrt(A)),

	%% suppose radius of Earth is 6372.8 km
	6372.8 * C.

spher_to_cart({Y1,Y0}) ->
  P = math:cos(Y0),
  X2 = math:sin(Y0),
  X1 = P * math:sin(Y1),
  X0 = P * math:cos(Y1),
  {X0,X1,X2}.

hypot(X1,X2) ->
	math:sqrt(math:pow(X1,2)+math:pow(X2,2)).

cart_to_spher({X0,X1,X2}) -> %return vector, vlen
  P = hypot(X0, X1),
  Y1 = math:atan2(X1, X0),
  Y0 = math:atan2(X2, P),
  {Y1,Y0}.

rotate({X0,X1,X2}, A, I) ->
	C = math:cos(A),
	S = math:sin(A),
	J = (I+1) rem 3,
	K = (I-1) rem 3,
	XJ = case J of 0 -> X0; 1 -> X1; 2 -> X2 end,
	XK = case K of 0 -> X0; 1 -> X1; 2 -> X2 end,
	OXJ = XJ * C + XK * S,
	OXK = -XJ * S + XK * C,
	{
	 case {J, K} of {0, _} -> OXJ; {_, 0} -> OXK; _ -> X0 end,
	 case {J, K} of {1, _} -> OXJ; {_, 1} -> OXK; _ -> X1 end,
	 case {J, K} of {2, _} -> OXJ; {_, 2} -> OXK; _ -> X2 end
	}.

azimuth(S,D) ->
	{AZ,_Dist} = sphere_inverse(S,D),
	AZ.

dist(S,D) ->
	{_AZ,Dist} = sphere_inverse(S,D),
	Dist.

sphere_inverse({S1,S2},{D1,D2}) ->
	{O1,O2}=sphere_inverser(
		  {S1*math:pi()/180,S2*math:pi()/180},
		  {D1*math:pi()/180,D2*math:pi()/180}
			      ),
	{O1*180/math:pi(),O2*6372.8}.

sphere_inverser({P1X,P1Y}, P2) ->
  X=spher_to_cart(P2),
  X1=rotate(X, P1X, 2),
  X2=rotate(X1, math:pi()/2 - P1Y, 1),
  {PT1,PT0}=cart_to_spher(X2),
  {math:pi() - PT1, math:pi()/2 - PT0}.

sphere_direct({S1,S2},Azi, Dist) ->
	{O1,O2}=sphere_directr({S1*math:pi()/180,S2*math:pi()/180},
			       Azi*math:pi()/180,
			       (Dist/6372.8)
			      ),
	{O1*180/math:pi(),O2*180/math:pi()}.

sphere_directr({S1,S2},Azi, Dist) ->
   %double pt[2], x[3];
  PT0 = math:pi()/2 - Dist,
  PT1 = math:pi() - Azi,
  X=spher_to_cart({PT1,PT0}),			% сферические -> декартовы
  X2=rotate(X, S2 - math:pi()/2, 1),	% первое вращение
  X3=rotate(X2, -S1, 2),				% второе вращение
  cart_to_spher(X3).	        		% декартовы -> сферические
 

