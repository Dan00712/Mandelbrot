using DrWatson
@quickactivate "MandelbrotProperly"
using Plots; gr()

include(srcdir() * "\\Mandelbrot.jl")
const mandelbrot_series_bound = Mandelbrot.mandelbrot_series_bound

const x_limit   = 2
const y_limit   = 2
const step_size = 0.0085

function display_mandelbrot(fn::String, x_range = -x_limit:step_size:x_limit-0.7, y_range = -y_limit:step_size:y_limit)
	n_till_escape   = Array{Float32}(undef, 0)

	for x in x_range
		for y in y_range
			escapes_after = mandelbrot_series_bound(x + y*im, 30, 2)

			append!(n_till_escape, escapes_after)
		end
	end

	GC.gc()

	colorData = reshape(n_till_escape, length(y_range), length(x_range))
	heatmap(x_range, y_range, colorData)
	#gui()

	savefig(fn)
	#readline()
end

function display_julia(c ::Number, x_range=-x_limit:step_size:x_limit, y_range = -y_limit:step_size:y_limit	)
	n_till_escape   = Array{Float32}(undef, 0)

	for x in x_range
		for y in y_range
			escapes_after = Mandelbrot.julia_series_bound(c, x + y*im, 30, 2)

			append!(n_till_escape, escapes_after)
		end
	end

	GC.gc()

	colorData = reshape(n_till_escape, length(y_range), length(x_range))
	
	
	heatmap(x_range, y_range, colorData, legend= :none)
	gui()
end


for i in -2:0.01:2
	display_julia(i)
end

println("finished")
readline()