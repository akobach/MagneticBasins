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
                        0.6, # a
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
                            2.0, # r in velocity space
                            10, # number of samples
                            N # 10^N corresponds to max precision of zoom
                            )  

basin_plot_v0([0., 0.], p, basin_colors, LinRange(-500, 500, 200), LinRange(-500, 500, 200), 1.32)
#basin_plot_v0([0., 0.], p, basin_colors, LinRange(-0.14850, -0.14840, 500), LinRange(-1e-8, 1e-8, 500), 0.5)
#basin_plot_xaxis(p, basin_colors, LinRange(-1, 1, 500), LinRange(-1, 1, 500))
#basins_plot_along_circle([0., 0.], p, LinRange(3.139349931015131, 3.139349931015133, 100), 0.5)
#plot_basin_lengths(p, zoom, T)

#basin_plot_x0([0.,0.], p, basin_colors, LinRange(-1.5, 1.5, 500))
#basin_plot_v0([0., 0.], p, basin_colors, LinRange(-1, 1, 500), LinRange(-1, 1, 500), 0.5)

#basins_plot_along_circle([0., 0.], p, LinRange(0, 2*π, 100), 0.5)
#basins_plot_along_circle([0., 0.], p, LinRange(1.0154642920694281, 1.0789308103237674, 100), 0.5)
#basins_plot_along_circle([0., 0.], p, LinRange(1.044953785399727, 1.0455948613416903, 100), 0.5)
#basins_plot_along_circle([0., 0.], p, LinRange(1.044953785399727, 1.0449602609142923, 100), 0.5)
#basins_plot_along_circle([0., 0.], p, LinRange(1.0449547665382974, 1.0449548319475355, 100), 0.5)
#basins_plot_along_circle([0., 0.], p, LinRange(1.0449548279833392, 1.0449548286440387, 100), 0.5)
#basins_plot_along_circle([0., 0.], p, LinRange(1.0449548286173438, 1.0449548286240176, 100), 0.5)

#plot_basin_lengths(p, zoom, T)

#plot_basin_spectra_a(T, N)

#plot_basin_spectra_r(T, N)