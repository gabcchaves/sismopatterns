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
	if typeof(values[1]) != Float64
		numeric_values = map(x -> parse(Float64, x), values)
		return length(numeric_values) != 0 ? reduce(+, numeric_values) / length(numeric_values) : 0
	else
		return length(values) != 0 ? reduce(+, values) / length(values) : 0
	end
end


# Função para mapear a média anual de algumas variáveis, por intervalo de
# tempo.
function map_annual_avg(data_frame, fieldname, t0, t1)
	df = clip_by_time(data_frame, t0, t1)
	array = []
	for year in t0:t1
		chunk_year = DataFrame(
			filter(
				row -> occursin(string(year), row.time),
				df
			)
		)
		if fieldname in names(chunk_year)
			numeric_values = filter(x -> !isempty(x), chunk_year[!, Symbol(fieldname)])
			avg = compute_arithmetic_avg(numeric_values)
			push!(array, avg)
		end
	end
	return array
end


# Função para recortar por intervalo de tempo.
function clip_by_time(data_frame, t0, t1)
	if t0 <= t1
		return DataFrame(
			filter(
				row -> year(DateTime(row.time, DateFormat("yyyy-mm-ddTHH:MM:SS.sssZ"))) >= t0 &&
				year(DateTime(row.time, DateFormat("yyyy-mm-ddTHH:MM:SS.sssZ"))) <= t1,
				data_frame
			)
		)
	else
		throw(Exception("Limite inferior do intervalo deve ser menor ou igual ao limite superior."))
	end
end


# Função principal.
function main()
	parsed_args = parse_cli_args()
	input_file = parsed_args["input"]
	output_file = parsed_args["output"]

	df = fetch_data(input_file, ["time", "mag", "depth", "longitude", "latitude"])

	mag = map_annual_avg(df, "mag", 1980, 2020)
	depth = map_annual_avg(df, "depth", 1980, 2020)

	#df1 = clip_by_time(df, 2000, 2020)
	scatter(depth, mag, markersize = 5, markeralpha = 1, markerstrokewidth = 0, legend = false)
	##scatter(df1.depth, df1.mag, markersize = 5, markeralpha = 1, markerstrokewidth = 0, legend = false)
	title!("Dispersão")
	xlabel!("Profundidade")
	ylabel!("Magnitude")
	plot!()
	savefig(length(output_file) > 0 ? output_file : string(output_file, ".png"))
end


main()

#compute_arithmetic_avg([1, 2, 3, 4, 5])
