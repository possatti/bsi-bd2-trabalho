#!/usr/bin/python3

import random

# Definições.
ARQUIVO_COM_NOMES = "Dados/Nomes de Pessoas.txt"
ARQUIVO_DE_SAIDA = "SQL Gerado/Motorista.sql"

# Define o id com que o motorista será inserido.
__idMotorista = 1 # Primeiro id.

# Controla o incremento dos dados únicos.
__incrementoCPF = 233 # Qualquer número de 3 digitos pequeno.
__incrementoRG = 321 # Qualquer número de 3 digitos pequeno.
__incrementoCNH = 153 # Qualquer número de 3 digitos pequeno.

NUMERO_DE_MOTORISTAS = 100

# Retorna o número e o incrementa.
def nextIdMotorista():
	global __idMotorista
	id = __idMotorista
	__idMotorista += 1
	return id

def cpfAleatorioEUnico():
	cpf = ""
	cpf += random.choice("0123456789")
	cpf += random.choice("0123456789")
	cpf += random.choice("0123456789")
	cpf += "."

	# Digitos não aleatórios.
	global __incrementoCPF
	digitosDoMeio = __incrementoCPF
	__incrementoCPF += 1
	cpf += str(digitosDoMeio)

	cpf += "."
	cpf += random.choice("0123456789")
	cpf += random.choice("0123456789")
	cpf += random.choice("0123456789")
	cpf += "-"
	cpf += random.choice("0123456789")
	cpf += random.choice("0123456789")
	return cpf

def rgAleatorioEUnico():
	rg = ""
	rg += random.choice("0123456789")
	rg += random.choice("0123456789")
	rg += random.choice("0123456789")

	# Digitos não aleatórios.
	global __incrementoRG
	digitosDoMeio = __incrementoRG
	__incrementoRG += 1
	rg += str(digitosDoMeio)

	rg += random.choice("0123456789")
	return rg

def cnhAleatorioEUnico():
	cnh = ""
	cnh += random.choice("0123456789")
	cnh += random.choice("0123456789")
	cnh += random.choice("0123456789")
	cnh += random.choice("0123456789")

	# Digitos não aleatórios.
	global __incrementoCNH
	digitosDoMeio = __incrementoCNH
	__incrementoCNH += 1
	cnh += str(digitosDoMeio)

	cnh += random.choice("0123456789")
	cnh += random.choice("0123456789")
	cnh += random.choice("0123456789")
	cnh += random.choice("0123456789")
	return cnh

def telefoneAleatorio():
	# DDD
	telefone = "("
	telefone += random.choice("123456789")
	telefone += random.choice("123456789")
	telefone += ")"

	# Número
	if random.choice([True, False]):
		telefone += "3"
	else:
		telefone += random.choice(["99", "98"])
	telefone += random.choice("0123456789")
	telefone += random.choice("0123456789")
	telefone += random.choice("0123456789")
	telefone += "-"
	telefone += random.choice("0123456789")
	telefone += random.choice("0123456789")
	telefone += random.choice("0123456789")
	telefone += random.choice("0123456789")
	return telefone


def booleanAleatorio():
	# FIXME: Colocar isso um pouco aleatorio.
	return random.choice(["false", "true"])

# Retorna uma query sql para inserir um motorista na tabela.
def insert( nomes ):
	# Esse id irá servir para a chave primária e as estrangeiras.
	id = nextIdMotorista()
	idStr = str(id)
	
	sql = "INSERT INTO Motorista(id, cpf, nome, cnh, rg, telefone, disponivel, endereco_id, veiculo_id)\n"
	sql +="VALUES (" + idStr
	sql +=", '" + cpfAleatorioEUnico() + "'"
	sql +=", '" + nomes[id - 1] + "'"
	sql +=", '" + cnhAleatorioEUnico() + "'"
	sql +=", '" + rgAleatorioEUnico() + "'"
	sql +=", '" + telefoneFixoAleatorio() + "'"
	sql +=", " + booleanAleatorio()
	sql +=", " + idStr
	sql +=", " + idStr + ");\n"
	return sql

def lerLinhaPorLinha( caminho ):
	# Puxa cada linha para uma lista.
	with open(caminho, "r") as arq:
		linhas = arq.readlines()

	# Limpa as quebras de linhas nos nomes dos linhas.
	for i in range(len(linhas)):
		linhas[i] = linhas[i].strip()

	return linhas

# Carrega os nomes.
nomes = lerLinhaPorLinha(ARQUIVO_COM_NOMES)

# Dá uma nova seed ao random.
random.seed()

# Abre o arquivo onde será escrito o SQL.
with open(ARQUIVO_DE_SAIDA, "w") as arqSaida:
	# Coloca um cabeçalho para o arquivo.
	arqSaida.write("-- Popula a tabela Motorista.\n\n")

	# Escreve todas as queries para um arquivo.
	for x in range(NUMERO_DE_MOTORISTAS):
		arqSaida.write(insert(nomes) + "\n")
