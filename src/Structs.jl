struct model_parameters{T}
    ω::T
    a::T
    h::T
    x̃ₘ::NTuple{3, NTuple{2,T}}
    tspan::Tuple{Int64, Int64}
    abstol::T
    reltol::T
end


mutable struct edge_ledger{T}
    min::T # min of sampling range
    max::T # max of sampling range
    left_basin::Int64 # left most basin
    right_basin::Int64 # right most basin
    num_zooms::Int64 # number of zooms on range with two basins
    finished::Bool # whether it's done zooming
end


struct zoom_parameters{T, N}
    u0::Array{T, 1} # initial values of x and y
    cdu0::Tuple{T, T} # center of velocity circle
    r::T # radius of velocity circle
    n_samples::Int64 # number of samples between min and max
    prec::T # 10^prec is the maximum precision of the zoom
end


struct circle{T}
    θ::T
    vx::T
    vy::T
end