import random

# Definições.
ARQUIVO_DE_SAIDA = "SQL Gerado/Pedido.sql"
NUMERO_DE_SERVICOS = 100;
UNIDADES = ["cabeças", "unidades", "gramas", "kilogramas"]
TIPO_DE_SERVICOS = ["NORMAL", "ECONOMICO", "EXPRESSO"]
NUMERO_DE_EMPRESAS = 100
NUMERO_DE_TIPOS_DE_CARGA = 10
DESCRICOES = [
"Pegaro máximo de estradas livres.",
"Passar apenas por caminhos asfaltados.",
"Evitar caminhos esburacados, a carga é muito sensível.",
"A carga deve estar com gps, por toda a viagem.",
"Em caso de acidentes, muito cuidado com a carga, pois é altamente inflamável.",
"A entrega deve ser feitas em mãos e com assinatura do dono.",
"Atrasos não serão tolerados para essa entrega.",
"A carga será verificada por um especialista que estará no local de entrega. E somente pode ser entregue com a aprovação assinada do especialista.",
"A entrega deve ser feita pela manhã.",
"A carga deve ser deixada no campo ao lado do prédio principal.",
"A entrega não pode demorar. Em caso de atraso, deve ser avisado que o serviço não será cobrado. Este é um cliente importante para a empresa, e não podemos desapontá-los",
]
PRODUTOS = [
"Madeira",
"Cosméticos",
"Faca",
"Chaira",
"Tesouro",
"Mesa",
"Cadeira",
"Notebook",
"Tabuleiro de Xadrez",
"Bíblia",
"Mochila",
"Bolsa",
"Televisor",
"Ar condicionado",
"Livro",
"Caderno",
"Caneta",
"Lápis"
]
DISTANCIA_MAXIMA = 1200
UNIDADES_DE_DISTANCIA = [
'Km',
'milhas'
]

# Variável de controle do id dos serviços.
__idServico = 1 # Primeiro id.

# Variável de controle do id dos endereços. Que serão usados
# como chave estrangeira para definir a origem e o destino do
# serviço.
__idEndereco = 201 # Primeiro id.

# Retorna o próximo id de telefone.
def nextIdServico():
	global __idServico
	id = __idServico
	__idServico += 1
	return id;

def nextIdEndereco():
	global __idEndereco
	id = __idEndereco
	__idEndereco += 1
	return id

def idTipoCargaAleatorio():
	return random.randint(1, NUMERO_DE_TIPOS_DE_CARGA)

def idEmpresaAleatorio():
	return random.choice(range(1, NUMERO_DE_EMPRESAS + 1))

def tipoServicoAleatorio():
	return random.choice(TIPO_DE_SERVICOS)

def quantidadeAleatoria():
	quantidade = ""
	quantidade += random.choice("123456789")
	quantidade += random.choice("0123456789")
	quantidade += random.choice("0123456789")
	return quantidade

def unidadeAleatoria():
	return random.choice(UNIDADES)

def dataAleatoria():
	data = "2011"

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

def distanciaAleatoria():
	distancia = str(random.choice(range(1, DISTANCIA_MAXIMA)))
	return distancia

def unidadeDistanciaAleatoria():
	return random.choice(UNIDADES_DE_DISTANCIA)

def getDescricaoAleatoria():
	descricao = random.choice(DESCRICOES)
	descricao = "'" + descricao + "'"
	return random.choice([descricao, "null"])

def produtoAleatorio():
	return random.choice(PRODUTOS)

def precoAleatorio():
	preco = random.choice("123456789")
	preco += random.choice("0123456789")
	preco += random.choice("0123456789")
	preco += "."
	preco += random.choice("0123456789")
	preco += random.choice("0123456789")
	return preco

def insert():
	id = str(nextIdServico())

	sql = "INSERT INTO Pedido(id, timestamp_requisicao, produto, qtd_volumes, peso_encomenda, distancia, preco_frete, observacoes, status)\n"
	sql +="VALUES (" + str(id)
	sql +=", '" + dataAleatoria() + "'"
	sql +=", '" + produtoAleatorio() + "'"
	sql +=", null"
	sql +=", null"
	sql +=", '" + distanciaAleatoria() + "'"
	sql +=", '" + precoAleatorio() + "'"
	sql +=", null"
	sql +=", 'EM_PROCESSAMENTO'"
	sql +=");\n"
	return sql

# Dá uma nova seed ao random.
random.seed()

# Abre o arquivo onde será escrito o SQL.
with open(ARQUIVO_DE_SAIDA, "w") as arqSaida:
	# Coloca um cabeçalho para o arquivo.
	arqSaida.write("-- Popula a tabela Pedido.\n\n")

	# Escreve todas as queries para um arquivo.
	for x in range(NUMERO_DE_SERVICOS):
		arqSaida.write(insert() + "\n")