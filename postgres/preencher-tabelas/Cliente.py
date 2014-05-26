#!/usr/bin/python3

import random

# Definições.
ARQUIVO_COM_NOMES_DE_EMPRESAS = "Dados/Nomes de Empresas.txt"
ARQUIVO_DE_SAIDA = "SQL Gerado/Cliente.sql"

# Define o id com que o motorista será inserido.
__idEmpresa = 1 # Primeiro id.

# Controla o incremento dos dados únicos.
__incrementoCNPJ = 247 # Qualquer número de 3 digitos pequeno.

NUMERO_DE_EMPRESAS = 100

# Retorna o número e o incrementa.
def nextIdEmpresa():
	global __idEmpresa
	id = __idEmpresa
	__idEmpresa += 1
	return id

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

def cnpjAleatorioEUnico():
	cnpj = ""
	cnpj += random.choice("0123456789")
	cnpj += random.choice("0123456789")
	cnpj += "."

	# Digitos não aleatórios.
	global __incrementoCNPJ
	digitosDoMeio = __incrementoCNPJ
	__incrementoCNPJ += 1
	cnpj += str(digitosDoMeio)

	cnpj += "."
	cnpj += random.choice("0123456789")
	cnpj += random.choice("0123456789")
	cnpj += random.choice("0123456789")
	cnpj += random.choice(["/0001", "/0002"])
	cnpj += "-"
	cnpj += random.choice("0123456789")
	cnpj += random.choice("0123456789")

	return cnpj

# Retorna uma query sql para inserir um motorista na tabela.
def insert( nomes ):
	# Esse id irá servir para a chave primária e as estrangeiras.
	id = nextIdEmpresa()
	
	sql = "INSERT INTO Cliente(id, cnpj, nome, telefone, endereco_id)\n"
	sql +="VALUES (" + str(id)
	sql +=", '" + cnpjAleatorioEUnico() + "'"
	sql +=", '" + nomes[id - 1] + "'"
	sql +=", '" + telefoneAleatorio() + "'"
	sql +=", " + str(id + 100) + ");\n"
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
empresas = lerLinhaPorLinha(ARQUIVO_COM_NOMES_DE_EMPRESAS)

# Dá uma nova seed ao random.
random.seed()

# Abre o arquivo onde será escrito o SQL.
with open(ARQUIVO_DE_SAIDA, "w") as arqSaida:
	# Coloca um cabeçalho para o arquivo.
	arqSaida.write("-- Popula a tabela Cliente.\n\n")

	# Escreve todas as queries para um arquivo.
	for x in range(NUMERO_DE_EMPRESAS):
		arqSaida.write(insert(empresas) + "\n")
