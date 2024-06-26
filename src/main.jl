using Revise
using BenchmarkTools
using ProgressMeter
using DoubleFloats
include("Structs.jl")
include("BasinFuncs.jl")
include("plots.jl")

#T = BigFloat
#N = -24

T = Float64
N = -14

#T = Double64 
#N = -20


p = model_parameters{T}(0.5, # ω
                        0.2, # a
                        0.2, # h    
                        (   (1/√3., 0.), # x̃₁
                            (-1/(2*√3.), -1/2.), # x̃₂
                            (-1/(2*√3.), 1/2.) # x̃₃
                        ), 
                        (0,100), # tspan
                        10.0^N, # abstol
                        10.0^N # reltol
                        )



# make basin plot
basin_colors = [RGB(252/255, 194/255, 3/255), 
                RGB(3/255, 107/255, 252/255), 
                RGB(252/255, 3/255, 128/255)]


zoom = zoom_parameters{T, N}([0., 0.], # [x0, y0] initial positions
                            (0., 0.), # center of velocity circle
                            0.5, # r in velocity space
                            10, # number of samples when doing zoom procedure
                            N # 10^N corresponds to max precision of zoom
                            )  


# plot basins in (x0,y0) plane, assuming dx0=dy0=0
#basin_plot_x0([0.,0.], p, basin_colors, LinRange(-1.5, 1.5, 100))

# plot basins in (dx0,dy0) plane, assuming x0=y0=0, with circle centered at (dx0,dy0)=0
#basin_plot_v0([0., 0.], p, basin_colors, LinRange(-1, 1, 500), LinRange(-1, 1, 100), 0.5)

# plot for sanity check of basins along circle in velocity space
#basins_plot_along_circle([0., 0.], p, LinRange(0, 2*π, 100), 0.5)

# plot a histogram of basin lengths along circle
plot_basin_lengths(p, zoom, T)

# scratch work, ignore for now
#plot_basin_spectra_a(T, N)
#plot_basin_spectra_r(T, N)