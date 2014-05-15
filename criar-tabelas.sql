CREATE TABLE endereco (
	id SERIAL PRIMARY KEY,
	cep CHAR(9) NOT NULL,
	estado VARCHAR(2) NOT NULL,
	cidade VARCHAR(255) NOT NULL,
	bairro VARCHAR(255) NOT NULL,
	logradouro VARCHAR(255) NOT NULL,
	numero VARCHAR(10),

	CONSTRAINT uniques_endereco UNIQUE(cep, bairro, logradouro),

	CONSTRAINT formato_cep CHECK(cep ~ '^\d{2}\.\d{3}-\d{3}$'),
	CONSTRAINT formato_estado CHECK(estado ~ '^[A-Z]{2}$'),
	CONSTRAINT formato_numero CHECK(numero ~ '^\d{1-10}|$')
);

CREATE TABLE veiculo (
	id SERIAL PRIMARY KEY,
	placa VARCHAR(9) NOT NULL,
	marca VARCHAR(45) NOT NULL,
	modelo VARCHAR(45) NOT NULL,

	CONSTRAINT unique_placa UNIQUE(placa),
	CONSTRAINT formato_placa CHECK(placa ~ '^[A-Z]{3}-\d{4}$')
);

CREATE TABLE motorista (
	id SERIAL PRIMARY KEY,
	cpf VARCHAR(14) NOT NULL,
	nome VARCHAR(255) NOT NULL,
	cnh VARCHAR(20) NOT NULL,
	rg VARCHAR(45) NOT NULL,
	telefone VARCHAR(14),
	disponivel BOOLEAN NOT NULL,
	endereco_id INT REFERENCES endereco,
	veiculo_id INT REFERENCES veiculo,

	CONSTRAINT unique_cpf UNIQUE(cpf),
	CONSTRAINT unique_rg UNIQUE(rg),
	CONSTRAINT unique_motorista_endereco_id UNIQUE(endereco_id),
	CONSTRAINT unique_veiculo_id UNIQUE(veiculo_id),

	CONSTRAINT formato_cpf CHECK(cpf ~ '^\d{3}\.\d{3}\.\d{3}-\d{2}$'),
	CONSTRAINT formato_telefone CHECK(telefone ~ '^\(\d{2}\)(\d)?\d{4}-\d{4}$')
);

CREATE TABLE cliente (
	id SERIAL PRIMARY KEY,
	cnpj VARCHAR(18) NOT NULL UNIQUE,
	nome VARCHAR(255) NOT NULL,
	telefone VARCHAR(14),
	endereco_id INT REFERENCES endereco,

	CONSTRAINT unique_cnpj UNIQUE(cnpj),
	CONSTRAINT unique_cliente_endereco_id UNIQUE(endereco_id)
	
	CONSTRAINT formato_cnpj CHECK(cpf ~ '^\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}$'),
	CONSTRAINT formato_telefone CHECK(telefone ~ '^\(\d{2}\)(\d)?\d{4}-\d{4}$')
);

CREATE TABLE pedido (
	id SERIAL PRIMARY KEY,
	timestamp_requisicao TIMESTAMP NOT NULL,
	produto VARCHAR(255) NOT NULL,
	qtd_volumes INT,
	peso_encomenda INT,
	distancia INT,
	preco_frete DECIMAL(10,2),
	observacoes VARCHAR(255),
	status VARCHAR(15) NOT NULL,
	cliente_id INT REFERENCES cliente,
	endereco_origem INT REFERENCES endereco,
	endereco_detino INT REFERENCES endereco,

	CONSTRAINT uniques_cliente UNIQUE(timestamp_requisicao, cliente_id),

	CONSTRAINT enum_status
	CHECK (produto LIKE 'EM_PROCESSAMENTO'
		OR produto LIKE 'EM_SEPARACAO'
		OR produto LIKE 'ENVIADO'
		OR produto LIKE 'RECEBIDO'
		)

	/**
	 * TODO:
	 * Campos QTD_VOLUMES E PESO_ENCOMENDA
	 * são a soma desses atributos de todas as
	 * viagens associadas ao PEDIDO.
	 */
);

CREATE TABLE viagem (
	id SERIAL PRIMARY KEY,
	qtd_volumes INT NOT NULL,
	peso_encomenda INT NOT NULL,
	timestamp_inicio TIMESTAMP,
	timestamp_fim TIMESTAMP,
	observacoes VARCHAR(255),
	motorista_id INT REFERENCES motorista,
	pedido_id INT REFERENCES pedido,

	CONSTRAINT uniques_viagem UNIQUE(timestamp_inicio, motorista_id)
);
