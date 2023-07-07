using ArgParse, CSV

function parse_arguments()
	s = ArgParseSettings()

	@add_arg_table s begin
		"--help"
			help = "Exibe dicas de uso do programa."
		"--input", "-i"
			help = "Recebe caminho do arquivo de entrada contendo os dados."
		"--output", "-o"
			help = "Recebe o caminho do arquivo de saída dos resultados."
	end

	return parse_args(s)
end

# Função que recebe o caminho 
function parse_input_csv()
end

function main()
	parsed_args = parse_arguments()
	println("Parsed arguments:")
	for (arg,val) in parsed_args
		println(" $arg => $val")
	end
end

main()
