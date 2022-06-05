module Mandelbrot

export mandelbrot_step, mandelbrot_series, julia_series_bound

function mandelbrot_step(c::Number, z::Number)
	return z^2 + c
end

function mandelbrot_series(c::Number, iterations::Int, chan::Channel{Number})
	#println("in task")
	z = mandelbrot_step(c, 0)
	put!(chan, z)

	for _ in 1:iterations
		z = mandelbrot_step(c, z)
		put!(chan, z)
	end

	close(chan)
end

function mandelbrot_series_bound(c::Number, max_iterations::Int, bind_n::Number)
	z = mandelbrot_step(c, 0)

	for i in 1:max_iterations
		z = mandelbrot_step(c, z)

		if abs(z) > bind_n
			return i
		end
	end

	return -1
end

function julia_series_bound(c::Number, z0::Number, max_iterations::Int, bind_n::Number)
	z = mandelbrot_step(c, z0)

	for i in 1:max_iterations
		z = mandelbrot_step(c, z)

		if abs(z) > bind_n
			return i
		end
	end

	return -1
end

end