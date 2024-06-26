using DifferentialEquations


function mag_force(u, x̃, p)
    x, y = u
    h = p.h

    den = sqrt((x - x̃[1])^2 + (y - x̃[2])^2 + h^2)^3

    ((x̃[1] - x)/den, (x̃[2] - y)/den)
end


function rhs!(ddu, du, u, p, t)
    x, y = u
    dx, dy = du
    ω, a = p.ω, p.a
    x̃ₘ = p.x̃ₘ

    ddu[1] = -ω^2*x - a*dx
    ddu[2] = -ω^2*y - a*dy

    for x̃ in x̃ₘ
        f₁, f₂ = mag_force(u, x̃, p)
        ddu[1] += f₁
        ddu[2] += f₂
    end
end


function get_basin(du0, u0, p)
    # define and solve ODE
    prob = SecondOrderODEProblem(rhs!, du0, u0, p.tspan, p)

    sol = solve(prob, 
                Vern9(),
                reltol = p.reltol, 
                abstol = p.abstol, 
                save_everystep = false, 
                save_start = false) 

    # find and return basin
    yₘ = sol[end][4] # final y position of pendulum
    return argmin(abs(x̃[2] - yₘ) for x̃ in p.x̃ₘ)
end


function circular_contour(zoom, edge, T)
    cx0, cy0 = zoom.cdu0
    r, θ₁, θ₂, nsteps = zoom.r, edge.min, edge.max, zoom.n_samples
    return [circle{T}(θ, cx0 + r*cos(θ), cy0 + r*sin(θ)) for θ in LinRange(θ₁, θ₂, nsteps)]
end


function find_basins_edges_helper(p, zoom, edge, T)
    # find basins along circular contour
    contour_steps = circular_contour(zoom, edge, T)
    basins_sample = [get_basin([circ.vx, circ.vy], zoom.u0, p) for circ in contour_steps]

    # locate the edges of basins
    stack = []
    for i in 1:(length(basins_sample)-1)
        if basins_sample[i] != basins_sample[i+1]
            new_edge = edge_ledger{T}(contour_steps[i].θ, 
                                        contour_steps[i+1].θ,
                                        basins_sample[i], 
                                        basins_sample[i+1],
                                        0,
                                        false)
            push!(stack, new_edge)
        end
    end

    if length(stack) == 1
        stack[1].num_zooms = edge.num_zooms + 1
    end

    return stack
end


function finished_zooming(zoom, edges)
    for edge in edges
        if edge.finished == false
            return false
        end
    end
    return true
end


function find_basin_edges!(p, zoom, T)

    starting_edge = edge_ledger{T}( 0., # min
                                    2*π, #  max
                                    0, # left basin
                                    0, # right basin
                                    0, # number of zooms
                                    false # whether it's done zooming
                                    )

    edges = [starting_edge]
    
    while finished_zooming(zoom, edges) == false
        stack = []
        @showprogress for edge in edges
            if edge.max - edge.min < 10.0^zoom.prec
                edge.finished = true
                stack = vcat(stack, edge)
                continue
            end
            stack = vcat(stack, find_basins_edges_helper(p, zoom, edge, T))
        end
        edges = stack
        println("number of edges found:", length(edges))
    end

    for edge in edges
        println(edge.min, " & ", edge.max, " & ", edge.left_basin, " & ", edge.right_basin, raw" \\ ")
    end
    
    return edges
    
end


function get_basin_lengths(zoom, edges)
    basin_labels = [edge.right_basin for edge in edges]

    basin_angles = [edges[i+1].min - edges[i].max for i in 1:(length(edges)-1)]
    basin_angles = vcat(basin_angles, 2*π - edges[end].max + edges[1].min)
    
    basin_lengths = [zoom.r*(edges[i+1].min - edges[i].max) for i in 1:(length(edges)-1)]
    basin_lengths = vcat(basin_lengths, zoom.r*(2*π - edges[end].max + edges[1].min))

    println("\n")
    for i in 1:length(basin_angles)
        println(basin_angles[i], " & ", log10(basin_angles[i]), " & ", log10(zoom.r*basin_angles[i]), " & ", basin_labels[i], raw" \\ ")
    end

    return log10.(basin_lengths)
end
