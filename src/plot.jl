using Plots, CSV, DataFrames, ArgParse, Dates, IterTools, LsqFit


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


# Função para plotar o gráfico sobre campos dos dados.
function plot_graph(xdata, ydata, model, pfit, xlabel, ylabel, filename)
	try
		xplot = range(minimum(xdata), stop=maximum(xdata), length=100)
		yplot = model(xplot, pfit)

		scatter(xdata, ydata, label="Dados")
		plot!(xplot, yplot, title="Modelo Ajustado")

		xlabel!(xlabel)
		ylabel!(ylabel)
		title!("Modelo Ajustado")

		plot!()
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


# Função para ajustar o modelo que lhe for passado como argumento.
function fit(model, p0, xdata, ydata)
	if length(xdata) > length(ydata)
		xdata = xdata[1:length(ydata)]
	elseif length(ydata) > length(xdata)
		ydata = ydata[1:length(xdata)]
	end
	fit = curve_fit(model, xdata, ydata, p0)
	return coef(fit)
end


# Função principal.
function main()
	parsed_args = parse_cli_args()
	input_file = parsed_args["input"]
	output_file = parsed_args["output"]

	df = fetch_data(input_file, ["time", "mag", "depth", "longitude", "latitude"])

	mag = map_annual_avg(df, "mag", 1960, 2020)
	depth = map_annual_avg(df, "depth", 1960, 2020)

	model(x, c) = c[1].*x .+ 4.0
	#model(x, c) = (x .== 0.0 || x ) ? Inf : 1.0 ./ sqrt.(c[1] .* x)
	pfit = fit(model, [-1.0], depth, mag)
	println(pfit)
	plot_graph(depth, mag, model, pfit, "Profundidade", "Magnitude", output_file)

	##df1 = clip_by_time(df, 2000, 2020)
	#scatter(depth, mag, markersize = 5, markeralpha = 1, markerstrokewidth = 0, legend = false, color = :green)
	###scatter(df1.depth, df1.mag, markersize = 5, markeralpha = 1, markerstrokewidth = 0, legend = false)
	#title!("Dispersão")
	#xlabel!("Profundidade")
	#ylabel!("Magnitude")
	#plot!()
	#savefig(length(output_file) > 0 ? output_file : string(output_file, ".png"))
end


main()
