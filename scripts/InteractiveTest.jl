using DrWatson
@quickactivate "MandelbrotProperly"
using Plots; gr()
import GR
using Logging

include(joinpath(srcdir() , "Mandelbrot.jl"))


function mainloop()
	t = ""
	
	step_size = 0.005
	x_range_init = -2:step_size:2
	y_range_init = -2:step_size:2
	f = Mandelbrot.mandelbrot_series_bound

	state = InteractiveState(x_range_init, y_range_init, f)

	displayinteractive(state)
	while true
		t = readline()
		try
			if(startswith(t, "exit"))
				@info "Shutting down"
				break
			end

			args = split(t, " ")

			if(startswith(t, "re-plot"))
				displayinteractive(state)
				continue
			end

			if(startswith(t, "plot"))
				if length(args) < 2
					state = defaultranges(state)
				else
					state = parseranges(state, args)
				end
			
				displayinteractive(state)
				continue
			end

			if(startswith(t, "save"))
				savecurrentdata(state, args)
				continue
			end

			if startswith(t, "set")
				state = setswitch(state, args)
				displayinteractive(state)
				continue
			end
		catch e
			@error sprint(showerror, e)
		end
	end
end

function savecurrentdata(state ,args)
	@debug args
	@debug String(args[2])
	saveinteractive(state, plotsdir(String(args[2])))
end

function displayinteractive(state)
	@info "calculating manddelbrot series in range of X: $(state.x_range) and Y: $(state.y_range)"
	n_till_escape = calculatedata(state)

	GC.gc()

	@info "displaying data in heatmap..."
	colorData = reshape(n_till_escape, length(state.y_range), length(state.x_range))
	plt = heatmap(state.x_range, state.y_range, colorData)
	display(plt)
end

function saveinteractive(state ,filename::String)
	@info "calculating manddelbrot series in range of X: $(state.x_range) and Y: $(state.y_range)"
	n_till_escape = calculatedata(state)

	GC.gc()

	@info "rendering data in heatmap..."
	colorData = reshape(n_till_escape, length(state.y_range), length(state.x_range))
	plt = heatmap(state.x_range, state.y_range, colorData)

	@info "saving fig"
	savefig(plt, filename)
end

function calculatedata(state)
	n_till_escape = Array{Float32}(undef, 0)

	for x in state.x_range
		for y in state.y_range
			escapes_after = state.seriesfun(x + y*im, 30, 2)

			append!(n_till_escape, escapes_after)
		end
	end

	return n_till_escape
end

function defaultranges(state)
	step_size = 0.005

	x_range_tmp = -2:step_size:2
	y_range_tmp = -2:step_size:2

	return InteractiveState(x_range_tmp, y_range_tmp, state.seriesfun)
end

function parseranges(state, args)
	x_range_args = split(args[2], ":")
	y_range_args = split(args[3], ":")

	step_size = state.x_range[2] - state.x_range[1]

	x_range = parse(Float64, x_range_args[1]) : step_size : parse(Float64, x_range_args[2])
	y_range = parse(Float64, y_range_args[1]) : step_size : parse(Float64, y_range_args[2])

	return InteractiveState(x_range, y_range, state.seriesfun)
end

function setswitch(state, args)
	if(startswith(args[2], "res"))
		return setres(state, args)
	end

	if(startswith(args[2], "mode"))
		return setmode(state, args)
	end
	
	return state
end

function setres(state, args)
	step_size = parse(Float64 , args[3])
			
	x_range_tmp = state.x_range[1]:step_size:state.x_range[end]
	y_range_tmp = state.y_range[1]:step_size:state.y_range[end]

	return InteractiveState(x_range_tmp, y_range_tmp, state.seriesfun)
end

function setmode(state, args)
	if startswith(args[3], "mb")
		return InteractiveState(state.x_range, state.y_range, Mandelbrot.mandelbrot_series_bound)

	elseif startswith(args[3], "jl")
		c = parse(ComplexF64, args[4])
		return InteractiveState(
			state.x_range,
			state.y_range,
			(z0, p_x_range, p_y_range) -> Mandelbrot.julia_series_bound(c, z0, p_x_range, p_y_range)
		)
	end

	@warn "$(args[2]) not a valid mode..."
	return state
end

struct InteractiveState
	x_range::StepRangeLen
	y_range::StepRangeLen
	seriesfun::Function

	InteractiveState(x, y , f) = new(x, y, f)
end

mainloop()
