-- -----------------------------------------------------
-- Table cliente
-- -----------------------------------------------------
CREATE TABLE cliente (
    id SERIAL,
    cnpj CHAR(18) NOT NULL,
    nome VARCHAR(255) NOT NULL,
    telefone1 VARCHAR(14) NULL,
    telefone2 VARCHAR(14) NULL,

    PRIMARY KEY (id),
    CONSTRAINT unique_cnpj UNIQUE(cnpj)
);

-- -----------------------------------------------------
-- Table endereco
-- -----------------------------------------------------
CREATE TABLE endereco (
    id SERIAL,
    cep CHAR(10) NOT NULL,
    estado CHAR(2) NOT NULL,
    cidade VARCHAR(255) NOT NULL,
    bairro VARCHAR(255) NOT NULL,
    logradouro VARCHAR(255) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    ponto_referencia TEXT NULL,

    PRIMARY KEY (id),
    CONSTRAINT unique_endereco
        UNIQUE(cep, estado, cidade, bairro, logradouro, numero)
);

-- -----------------------------------------------------
-- Table motorista
-- -----------------------------------------------------
CREATE TABLE motorista (
    id SERIAL,
    cpf CHAR(14) NOT NULL,
    nome VARCHAR(255) NOT NULL,
    cnh VARCHAR(20) NOT NULL,
    rg VARCHAR(20) NOT NULL,
    telefone1 VARCHAR(14) NULL,
    telefone2 VARCHAR(14) NULL,
    disponivel BOOLEAN NOT NULL,

    PRIMARY KEY (id),
    CONSTRAINT unique_cpf UNIQUE(cpf),
    CONSTRAINT unique_cnh UNIQUE(cnh),
    CONSTRAINT unique_rg UNIQUE(rg)
);

-- -----------------------------------------------------
-- Table veiculo
-- -----------------------------------------------------
CREATE TABLE veiculo (
    id SERIAL,
    placa CHAR(8) NOT NULL,
    marca VARCHAR(45) NOT NULL,
    modelo VARCHAR(45) NOT NULL,

    PRIMARY KEY (id),
    CONSTRAINT unique_placa UNIQUE(placa)
);

-- -----------------------------------------------------
-- Table pedido
-- -----------------------------------------------------
CREATE TABLE pedido (
    id SERIAL,
    produto VARCHAR(255) NOT NULL,
    momento_pedido TIMESTAMP NOT NULL,
    situacao VARCHAR(45) NOT NULL,
    qtd_volumes INT NULL,
    peso_liquido DECIMAL(10,3) NULL,
    preco_frete DECIMAL(10,2) NULL,
    observacoes TEXT NULL,
    cliente_id INT NOT NULL,
    endereco_origem_id INT NOT NULL,
    endereco_destino_id INT NOT NULL,

    PRIMARY KEY (id),
    CONSTRAINT unique_pedido UNIQUE(momento_pedido, cliente_id),
    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES cliente (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_pedido_endereco_origem
        FOREIGN KEY (endereco_origem_id)
        REFERENCES endereco (id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_pedido_endereco_destino
        FOREIGN KEY (endereco_destino_id)
        REFERENCES endereco (id)
        ON DELETE RESTRICT
);

-- -----------------------------------------------------
-- Table viagem
-- -----------------------------------------------------
CREATE TABLE viagem (
    id SERIAL,
    momento_saida TIMESTAMP NULL,
    momento_chegada TIMESTAMP NULL,
    veiculo_id INT NOT NULL,

    PRIMARY KEY (id),
    CONSTRAINT unique_viagem UNIQUE(momento_saida, veiculo_id),
    CONSTRAINT fk_viagem_veiculo
        FOREIGN KEY (veiculo_id)
        REFERENCES veiculo (id)
        ON DELETE RESTRICT
);

-- -----------------------------------------------------
-- Table carga
-- -----------------------------------------------------
CREATE TABLE carga (
    pedido_id BIGINT NOT NULL,
    viagem_id BIGINT NOT NULL,
    qtd_volumes INT NULL,
    momento_carregamento TIMESTAMP NULL,
    momento_descarregamento TIMESTAMP NULL,

    PRIMARY KEY (pedido_id, viagem_id),
    CONSTRAINT fk_carga_pedido
        FOREIGN KEY (pedido_id)
        REFERENCES pedido (id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_carga_viagem
        FOREIGN KEY (viagem_id)
        REFERENCES viagem (id)
        ON DELETE RESTRICT
);

-- -----------------------------------------------------
-- Table motorista_veiculo
-- -----------------------------------------------------
CREATE TABLE motorista_veiculo (
    id SERIAL,
    veiculo_id INT NOT NULL,
    motorista_id INT NOT NULL,
    momento_alocacao TIMESTAMP NULL,
    momento_liberacao VARCHAR(45) NULL,

    PRIMARY KEY (id),
    CONSTRAINT unique_motorista_veiculo
        UNIQUE(veiculo_id, motorista_id, momento_alocacao),
    CONSTRAINT fk_veiculo_has_motorista_veiculo
        FOREIGN KEY (veiculo_id)
        REFERENCES veiculo (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_motorista_has_motorista_veiculo
        FOREIGN KEY (motorista_id)
        REFERENCES motorista (id)
        ON DELETE CASCADE
);