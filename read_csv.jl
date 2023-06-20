using CSV, DataFrames

file = "/home/gabriel/Documentos/Ufopa/bcc/4/calculo_numerico/projeto/Significant_Earthquakes.csv"

i = 0
for row in CSV.File(file, missingstring=["missing"])
	if occursin(r"Japan", row.place) && occursin(r"20\d\d", row.time)
		global i += 1
		csv_row_string = ""
		for column in propertynames(row)
			csv_row_string *= string(getproperty(row, column))
		end
		println(join(row, ", "))
		#println("$(i) - Place=$(row.place), Time=$(row.time), Lat=$(row.latitude), Lon=$(row.longitude)")
	end
end
