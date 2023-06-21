using Plots, CSV, DataFrames, ArgParse, Dates, IterTools


# Função para receber argumentos passados ao programa.
function parse_cli_args()
	s = ArgParseSettings()

    @add_arg_table s begin
        "input"
            help = "Dados de entrada."
            required = true
		"output"
			help = "Dados de saída."
			required = false
    end

    return parse_args(s)
end


# Função que busca os dados a serem mapeados.
function fetch_data(path, fields)
	try
		df = CSV.File(
			path,
			missingstring=["missing"],
			select=fields
		)

		return df
	catch e
		println(e)
	end
end


# Função para plotar o gráfico dos dados.
function plot_graph(data_frame, field1, field2, filename)
	try
		x = data_frame[!, Symbol(field1)]
		y = data_frame[!, Symbol(field2)]
		plot(x, y, xlabel = field1, ylabel = field2, title = "Gráfico")
		savefig(occursin(".png", filename) ? filename : string(filename, ".png"))
	catch e
		println(e)
	end
end


# Função para computar média aritmética.
function compute_arithmetic_avg(values)
	return reduce(+, values) / length(values)
end


# Função para mapear a média anual de algumas variáveis.
function map_annual_avg(data_frame, fieldname)
	df = []

	for year = 2000:2020
		chunk = DataFrame(filter(row -> occursin(string(year), row.time), data_frame))
		avg = compute_arithmetic_avg(chunk[!, Symbol(fieldname)])
		push!(df, avg)
		println(avg)
	end

	return df
end


# Função para recortar por intervalo de tempo.
function clip_by_time(data_frame, t0, t1)
	println(filter(row -> parse(Int, row.time[1:4]) >= 2000, data_frame))
end


# Função principal.
function main()
	parsed_args = parse_cli_args()
	input_file = parsed_args["input"]
	output_file = parsed_args["output"]

	df = fetch_data(input_file, ["time", "mag", "depth", "longitude", "latitude"])

	mag = map_annual_avg(df, "mag")
	depth = map_annual_avg(df, "depth")

	#df1 = clip_by_time(df, 2000, 2020)
	scatter(depth, mag, markersize = 5, markeralpha = 1, markerstrokewidth = 0, legend = false)
	#scatter(df1.depth, df1.mag, markersize = 5, markeralpha = 1, markerstrokewidth = 0, legend = false)
	title!("Dispersão")
	xlabel!("Profundidade")
	ylabel!("Magnitude")
	plot!()
	savefig("annualavg.png")
end


main()

#compute_arithmetic_avg([1, 2, 3, 4, 5])
