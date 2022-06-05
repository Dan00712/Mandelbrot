using DrWatson
@quickactivate "MandelbrotProperly"

using UnPack
using JLD2

include(srcdir() * "\\Mandelbrot.jl")

function calc_data(c ,x_range, y_range)
	n_till_escape = Array{Float32}(undef, 0)

	for x in x_range
		for y in y_range
			escapes_after = Mandelbrot.julia_series_bound(c ,x + y*im, 30, 2)

			append!(n_till_escape, escapes_after)
		end
	end

	return n_till_escape
end

function make_sim(d::Dict)
	@unpack c, x_range, y_range = d

	n_till_escape = calc_data(c, x_range, y_range)
	fullDict = copy(d)
	fullDict["n_till_escape"] = n_till_escape

	return fullDict
end

function collect_and_save_data()
	dicts = create_dicts()
	for (i, d) in enumerate(dicts)
		data = make_sim(d)

		wsave(datadir("simulations", "sim_$(i).jld2"), data)
	end
end

function create_dicts()
	tmp_data = Dict(
		"c" => [.25, .27, .30, .35, .40],
		"x_range" => -2:.05:2,
		"y_range" => -2:.05:2
	)
	return dict_list(tmp_data)
end

collect_and_save_data()