using Plots
using LaTeXStrings
using Colors
using ThreadsX
using ProgressMeter
using Printf



function basin_plot_x0(du0, p, colors, steps)

    # get array of basins via threading
    result = ThreadsX.collect(get_basin(du0, [y,x], p) for x in steps, y in steps)
    
    # map from basin to colors
    result = colors[result]

    # plot
    fig = plot(steps, steps, result, 
        aspect_ratio = :equal,
        xlabel = L"x_0", 
        ylabel = L"y_0",
        xlims = (steps[1], steps[end]),
        ylims = (steps[1], steps[end]))

    #savefig(fig,"basins.pdf")
end


function circle(cx0, cy0, r, nsteps)
    θ = LinRange(0, 2π, nsteps)
    return cx0 .+ r*cos.(θ), cy0 .+ r*sin.(θ)
end


function basin_plot_v0(u0, p, colors, xsteps, ysteps, r)

    # get array of basins via threading
    result = ThreadsX.collect(get_basin([xdot,ydot], u0, p) for ydot in ysteps, xdot in xsteps)
    
    # map from basin to colors
    result = colors[result]

    # plot  
    plot(xsteps, ysteps, result, 
        aspect_ratio = abs(xsteps[1]-xsteps[2])/abs(ysteps[1]-ysteps[2]),
        yflip = true,
        xlabel = L"\dot{x}_0", 
        ylabel = L"\dot{y}_0",
        xlims = (xsteps[1], xsteps[end]),
        ylims = (ysteps[1], ysteps[end])) 
    
    plot!(circle(0, 0, r, 500),
            lw = 1,
            linecolor = :black,
            legend = false,
            fillalpha = 0)

    #savefig(fig,"basins.pdf")
end


function basin_plot_xaxis(p, colors, xdotsteps, xsteps)

    # get array of basins via threading
    result = ThreadsX.collect(get_basin([xdot,0], [x,0], p) for xdot in xdotsteps, x in xsteps)
    
    # map from basin to colors
    result = colors[result]

    # plot  
    plot(xsteps, xdotsteps, result, 
        aspect_ratio = :equal,
        yflip = true,
        xlabel = L"x_0", 
        ylabel = L"\dot{x}_0",
        xlims = (xdotsteps[1], xdotsteps[end]),
        ylims = (xsteps[1], xsteps[end])) 
    
    #savefig(fig,"basins.pdf")
end


function basins_plot_along_circle(u0, p, steps, r)

    result = ThreadsX.collect(get_basin([r*cos(θ), r*sin(θ)], u0, p) for θ in steps)

    println([[θ, b] for (θ,b) in zip(steps, result)])

    ticks = LinRange(steps[1], steps[end], 4)
    ticklabels = [ @sprintf("%5.15f",x) for x in ticks ]

    # plot  
    plot(steps, 
        result, 
        xticks = (ticks,ticklabels),
        xlabel = "radians",
        ylabel = "basin number",
        legend = false,
        lt = :scatter,
        xlims = (steps[1], steps[end])) 

end


function plot_basin_lengths(p, zoom, T)
    edges = find_basin_edges!(p, zoom, T)
    lengths = get_basin_lengths(zoom, edges)

    #xmin = zoom.prec + log10(zoom.r)
    #xmax = 1
    
    #ticks = xmin:2:xmax
    #ticklabels = [ @sprintf("%2.0f",x) for x in ticks ]

    xmin = -12
    xmax = -0.1
    ticks = LinRange(xmin, xmax, 6)
    ticklabels = [ @sprintf("%2.4f",x) for x in ticks ]

    histogram(lengths,
                bins=range(xmin, xmax, length=250),
                xticks = (ticks,ticklabels),
                legend = false,
                xlabel = L"\log_{10} \ell_b", 
                ylabel = "count",
                yaxis = :log
                )
end




function plot_basin_spectra_a(T, N)

    zoom = zoom_parameters{T, N}([0., 0.], # [x0, y0] initial positions
                                (0., 0.), # center of velocity circle
                                0.5, # r in velocity space
                                10, # number of samples
                                N # 10^N corresponds to max precision of zoom
                                )  

    results = []

    for a in 0.01:0.05:1.2
        p = model_parameters{T}(0.5, # ω
                                a, # a
                                0.2, # h    
                                (   (1/√3., 0.), # x̃₁
                                    (-1/(2*√3.), -1/2.), # x̃₂
                                    (-1/(2*√3.), 1/2.) # x̃₃
                                ), 
                                (0,100), # tspan
                                10.0^N, # abstol
                                10.0^N # reltol
                            )

        edges = find_basin_edges!(p, zoom, T)
        lengths = get_basin_lengths(zoom, edges)

        for l in lengths
            push!(results, [a, l])
        end


    end

    println(results)

    plot([r[1] for r in results], 
        [r[2] for r in results],
        seriestype = :scatter,
        legend = false,
        xlabel = L"a",
        ylabel = L"\log_{10} \ell_b",
        ylim = [zoom.prec, 0.5])
            

                
end


function plot_basin_spectra_r(T, N)

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

     

    results = []

    for r in 1.1:0.005:1.4
        println("Radius:", r)
        zoom = zoom_parameters{T, N}([0., 0.], # [x0, y0] initial positions
                                (0., 0.), # center of velocity circle
                                r, # r in velocity space
                                10, # number of samples
                                N # 10^N corresponds to max precision of zoom
                                ) 

        edges = find_basin_edges!(p, zoom, T)
        lengths = get_basin_lengths(zoom, edges)

        for l in lengths
            push!(results, [r, l])
        end


    end

    println(results)

    plot([r[1] for r in results], 
        [r[2] for r in results],
        seriestype = :scatter,
        legend = false,
        xlabel = L"r",
        ylabel = L"\log_{10} \ell_b",
        ylim = [zoom.prec, 0.5])
            

                
end

