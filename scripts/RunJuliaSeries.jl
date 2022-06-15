using DrWatson
@quickactivate "MandelbrotProperly"

using UnPack
using JLD2
using Logging

include(joinpath(srcdir() , "Mandelbrot.jl"))

function calc_data(c ,x_range, y_range)
	n_till_escape = Array{Float32}(undef, 0)

	data_dict = Dict{Tuple{Float64, Float64}, Int32}()

	for x in x_range
		for y in y_range
			escapes_after = Mandelbrot.julia_series_bound(c ,x + y*im, 30, 2)

			data_dict[(x,y)] = escapes_after
			#append!(n_till_escape, escapes_after)
		end
	end

	return data_dict
end

function make_sim(d::Dict)
	@unpack c, x_range, y_range = d

	data_dict = calc_data(c, x_range, y_range)
	fullDict = copy(d)
	fullDict["data_dict"] = data_dict

	return fullDict
end

function collect_and_save_data()
	dicts = create_dicts()
	for (i, d) in enumerate(dicts)
		@debug "getting data in iteration $i"
		data = make_sim(d)

		f = datadir("simulations", "sim_$(i).jld2")
		@debug "saving data into file $f"
		wsave(f, data)
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
