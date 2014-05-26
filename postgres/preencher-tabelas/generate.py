import subprocess

# Nome final do arquivo a ser gerado.
NOME_DO_ARQUIVO_GERADO = 'preencher-tabelas.sql'

# Chama os scripts para gerarem seus arquivos.
subprocess.call(['python3', 'Veiculo.py'])
subprocess.call(['python3', 'Endereco.py'])
subprocess.call(['python3', 'Motorista.py'])
subprocess.call(['python3', 'Cliente.py'])
subprocess.call(['python3', 'Pedido.py'])
subprocess.call(['python3', 'Viagem.py'])

# Junta todos os SQLs em um único arquivo.
# Atenção: A ordem importa! Devido as relações entre as tabelas,
#          algumas devem ser preenchidas primeiro.
SQLFiles = [
'SQL Gerado/Veiculo.sql',
'SQL Gerado/Endereco.sql',
'SQL Gerado/Motorista.sql',
'SQL Gerado/Cliente.sql',
'SQL Gerado/Pedido.sql',
'SQL Gerado/Viagem.sql',
]

# Junta todos os SQLs gerado em um arquivo só.
with open(NOME_DO_ARQUIVO_GERADO, "w") as arqSaida:
	for SQLFile in SQLFiles:
		with open(SQLFile, "r") as arqEntrada:
			for line in arqEntrada.readlines():
				arqSaida.write(line)
