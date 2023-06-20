using Plots, CSV, DataFrames, ArgParse, Dates


# Função para receber argumentos passados ao programa.
function parse_cli_args()
	s = ArgParseSettings()

    @add_arg_table s begin
        "input"
            help = "Dados de entrada."
            required = true
		"output"
			help = "Dados de saída."
			required = true
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
function plot_graph(data_frame)
	mag = data_frame.mag
	depth = data_frame.depth
	###long = data_frame.longitude
	###lat = data_frame.latitude
	plot(mag, depth, xlabel = "Magnitude", ylabel = "Profundidade", title = "Gráfico")
	savefig("result.png")
end


# Função principal.
function main()
	parsed_args = parse_cli_args()
	input_file = parsed_args["input"]
	output_file = parsed_args["output"]

	df = fetch_data(input_file, ["time", "mag", "depth", "longitude", "latitude"])

	plot_graph(df)
end


main()
