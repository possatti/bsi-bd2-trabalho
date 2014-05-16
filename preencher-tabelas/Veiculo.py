#!/usr/bin/python3

# Importações.
import random

# Definições.
ARQUIVO_DE_MODELOS = "Dados/Modelos de Caminhoes.txt"
ARQUIVO_DE_MARCAS = "Dados/Marcas de Caminhões.txt"
ARQUIVO_DE_SAIDA = "SQL Gerado/Veiculo.sql"
NUMERO_DE_VEICULOS = 100;
NUMERO_DA_PLACA_INICIAL = 2750

# Variável se incremento das placas.
__numeroDaPlaca = 0

# Variável de incremento de id dos veiculos.
__idVeiculo = 1 # Primeiro id

# Funções.
# Retorna um modelo de veículo aleatório.
def modeloAleatorio( modelos ):
	return random.choice(modelos)

def marcaAleatoria( marcas ):
	return random.choice(marcas)

# Retorna o próximo id de veículo.
def nextIdVeiculo():
	global __idVeiculo
	id = __idVeiculo
	__idVeiculo += 1
	return id;

# Retorna uma placa sequencial.
def placaSequencial():
	placa = ""

	# Anexa letras a placa.
	for i in range(3):
		placa += random.choice("ABCDEFGHIJKLMNOPQRSTUVWXYZ")

	# Anexa o hífen.
	placa += "-"

	# Anexa os números a placa.
	global __numeroDaPlaca
	__numeroDaPlaca = __numeroDaPlaca + 1
	placa += str(NUMERO_DA_PLACA_INICIAL + __numeroDaPlaca)

	return placa

# Lê os modelos do arquivo e os retorna.
def lerModelos():
	with open(ARQUIVO_DE_MODELOS, "r") as arqModelos:
		# Lê todas as linhas do arquivo.
		modelos = arqModelos.readlines()

		# Limpa os caracteres de quebra de linha e espaços.
		for i in range(len(modelos)):
			modelos[i] = modelos[i].strip()

		return modelos

def lerMarcas():
	with open(ARQUIVO_DE_MARCAS, "r") as arq:
		# Lê todas as linhas do arquivo.
		marcas = arq.readlines()

		# Limpa os caracteres de quebra de linha e espaços.
		for i in range(len(marcas)):
			marcas[i] = marcas[i].strip()

		return marcas

# Gera uma query sql para inserir um veiculo aleatório na tabela de
# veículos.
def insertVeiculoAleatorio( modelos ):
	sql = "INSERT INTO Veiculo(id, placa, marca, modelo)\n"
	sql +="VALUES (" + str(nextIdVeiculo()) + ", '" + placaSequencial() + "', '" + marcaAleatoria(marcas) + "', '" + modeloAleatorio(modelos) + "');\n"
	return sql

# Dá uma nova seed ao random.
random.seed()

# Lê os modelos
modelos = lerModelos()
marcas = lerMarcas()

# Escreve todas as queries para um arquivo.
with open(ARQUIVO_DE_SAIDA, "w") as arqSaida:
	arqSaida.write("-- Popula a tabela Veiculo.\n")
	for x in range(NUMERO_DE_VEICULOS):
		arqSaida.write(insertVeiculoAleatorio(modelos) + "\n")