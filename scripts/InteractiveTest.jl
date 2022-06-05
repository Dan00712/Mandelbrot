using DrWatson
@quickactivate "MandelbrotProperly"
using Plots; gr()
using Logging

include(srcdir() * "\\Mandelbrot.jl")


function main_loop()
	t = ""
	step_size = 0.005
	x_range = -2:step_size:2
	y_range = -2:step_size:2

	series_fun = Mandelbrot.mandelbrot_series_bound

	display_ia(series_fun, x_range, y_range)
	while true
		t = readline()

		if(startswith(t, "exit"))
			@warn "Shutting down"
			break
		end

		args = split(t, " ")
		#println(args)

		if(startswith(t, "re-plot"))
			display_ia(series_fun, x_range, y_range)
			continue
		end

		if(startswith(t, "plot"))
			if length(args) < 2
				step_size = 0.005

				x_range = -2:step_size:2
				y_range = -2:step_size:2
			else
				x_range_args = split(args[2], ":")
				y_range_args = split(args[3], ":")

				x_range = parse(Float64, x_range_args[1]) : step_size : parse(Float64, x_range_args[2])
				y_range = parse(Float64, y_range_args[1]) : step_size : parse(Float64, y_range_args[2])
			end
			
			display_ia(series_fun, x_range, y_range)
			continue
		end

		if(startswith(t, "save"))
			save_current_data(series_fun, args, x_range, y_range)
			continue
		end

		if startswith(t, "set")
			if(startswith(args[2], "res"))
				step_size = parse(Float64 , args[3])
			
				x_range_tmp = x_range[1]:step_size:x_range[end]
				y_range_tmp = y_range[1]:step_size:y_range[end]

				x_range = x_range_tmp
				y_range = y_range_tmp
			end

			if(startswith(args[2], "mode"))
				if startswith(args[3], "mb")
					series_fun = Mandelbrot.mandelbrot_series_bound

				elseif startswith(args[3], "jl")
					c = parse(ComplexF64, args[4])
					series_fun = (z0, p_x_range, p_y_range) -> Mandelbrot.julia_series_bound(c, z0, p_x_range, p_y_range)
				end
			end
			
			display_ia(series_fun ,x_range, y_range)
			continue
		end

	end
end

function save_current_data(series_fun ,args, x_range, y_range)
	@debug args
	@debug String(args[2])
	save_ia(series_fun, plotsdir() * "\\" * String(args[2]), x_range, y_range)
end

function display_ia(series_fun ,x_range, y_range)
	@info "calculating manddelbrot series in range of X: $(x_range) and Y: $(y_range)"
	n_till_escape = calc_data(series_fun, x_range, y_range)

	GC.gc()

	@info "displaying data in heatmap..."
	colorData = reshape(n_till_escape, length(y_range), length(x_range))
	plt = heatmap(x_range, y_range, colorData)
	gui(plt)
end

function save_ia(series_fun ,filename::String ,x_range, y_range)
	@info "calculating manddelbrot series in range of X: $(x_range) and Y: $(y_range)"
	n_till_escape = calc_data(series_fun, x_range, y_range)

	GC.gc()

	@info "rendering data in heatmap..."
	colorData = reshape(n_till_escape, length(y_range), length(x_range))
	plt = heatmap(x_range, y_range, colorData)

	@info "saving fig"
	savefig(plt, filename)
end

function calc_data(series_fun , x_range, y_range)
	n_till_escape = Array{Float32}(undef, 0)

	for x in x_range
		for y in y_range
			escapes_after = series_fun(x + y*im, 30, 2)

			append!(n_till_escape, escapes_after)
		end
	end

	return n_till_escape
end

main_loop()