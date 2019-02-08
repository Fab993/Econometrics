## BLP - Objective Function
# Fabrizio Leone
# 07 - 02 - 2019

function Obj_function(x0::Vector{Float64},X::Matrix{Float64},A::Matrix{Float64},
                     price::Vector{Float64},v::Matrix{Float64},TM::Int64,
                     sharesum::Matrix{Float64},share::Matrix{Float64},
                     Z::Matrix{Float64},W::Matrix{Float64})

#------------- Initialize Parameters-------------#
tol_inner  = 1.e-14;                                 # Tolerance for inner loop (NFXP)
theta1     = x0[1:5];                                # Linear parameters
theta2     = x0[6:9];                                # Non Linear Paramters
ii         = 0;
norm_max   = 1;
delta      = X*theta1;

while norm_max > tol_inner  && ii < 1000

     # Step 1: Simulated market shares
     num       = delta.*exp.([A price]*(theta2.*v)); # Numerator of simulated integral
     den       = ones(TM,1).+sharesum*num;           # Denominator of simulated integral
     den       = sharesum'*den;                      # Denominator of simulated integral
     sim_share = mean(num./den,dims=2);              # Simulated shares

     # Step 2: Compute a new delta by BLP inversion and compute norm_max
     global delta_new = delta.*(share./sim_share);   # BLP contraction mapping
     norm_max  = maximum(abs.(delta_new - delta));   # Find maximum of Euclidean distance
     delta     = delta_new;                          # Update delta
     ii        += 1                                  # Update counter

end

     # Step 3: Get the implied structural errors
     xi        = log.(delta_new) - X*theta1;         # Updated moment condition
     g         = Z'*xi;                              # Moment conditions GMM

     # Step 4: Update GMM objective function
     f         = tr(g'*W*g);                         # Take trace to ensure f is Float64

return f

end
