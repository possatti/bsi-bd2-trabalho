import random

# Definições.
ARQUIVO_DE_SAIDA = "SQL Gerado/Viagem.sql"
NUMERO_DE_PEDIDOS = 100;
NUMERO_DE_MOTORISTAS = 100;
NUMERO_DE_VIAGENS = 200;

# Variável de controle do id das viagens.
__idViagem = 1 # Primeiro id.

# Retorna o próximo id de transporte.
def nextIdViagem():
	global __idViagem
	id = __idViagem
	__idViagem += 1
	return id;

def idPedidoAleatorio():
	return random.randint(1, NUMERO_DE_PEDIDOS)

def idMotoristaAleatorio():
	return random.randint(1, NUMERO_DE_MOTORISTAS)

def quantidadeAleatoria():
	quantidade = ""
	quantidade += random.choice("1123456789")
	quantidade += random.choice("0123456789")
	return quantidade

def dataIniciouAleatoria():
	data = "2012"

	# Mês
	data += "-"
	data += str(random.choice(range(1, 13)))

	# Dia
	data += "-"
	data += str(random.choice(range(1, 29)))
	
	# Hora
	data += " "
	data += str(random.choice(range(0, 24)))

	# Minutos
	data += ":"
	data += str(random.choice(range(0, 60)))

	return data

def dataTerminouAleatoria():
	data = "'2013"

	# Mês
	data += "-"
	data += str(random.choice(range(1, 13)))

	# Dia
	data += "-"
	data += str(random.choice(range(1, 29)))
	
	# Hora
	data += " "
	data += str(random.choice(range(0, 24)))

	# Minutos
	data += ":"
	data += str(random.choice(range(0, 60)))
	data += "'"

	return random.choice([data, "null"])

def custoAleatorio():
	custo = ""
	custo += random.choice("1123456789")
	custo += random.choice("0123456789")
	custo += random.choice("0123456789")
	custo += "."
	custo += random.choice("0123456789")
	custo += random.choice("0123456789")

	return custo

def insert():
	sql = "INSERT INTO Viagem(id, timestamp_inicio, timestamp_fim, qtd_volumes, peso_encomenda, observacoes, motorista_id, pedido_id)\n"
	sql +="VALUES (" + str(nextIdViagem())
	sql +=", '" + dataIniciouAleatoria() + "'"
	sql +=", " + dataTerminouAleatoria()
	sql +=", " + quantidadeAleatoria()
	sql +=", " + quantidadeAleatoria()
	sql +=", null"
	sql +=", " + str(idMotoristaAleatorio())
	sql +=", " + str(idPedidoAleatorio())
	sql +=");\n"

	return sql

# Dá uma nova seed ao random.
random.seed()

# Abre o arquivo onde será escrito o SQL.
with open(ARQUIVO_DE_SAIDA, "w") as arqSaida:
	# Coloca um cabeçalho para o arquivo.
	arqSaida.write("-- Popula a tabela Viagem.\n\n")

	# Escreve todas as queries para um arquivo.
	for x in range(NUMERO_DE_VIAGENS):
		arqSaida.write(insert() + "\n")