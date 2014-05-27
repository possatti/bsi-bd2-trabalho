-- -----------------------------------------------------
-- Criação dos tipos e domínios
-- -----------------------------------------------------
CREATE TYPE STATUS_PEDIDO AS ENUM
    ('PREPARACAO', 'INICIADO', 'SUCESSO', 'FALHA');

CREATE DOMAIN D_TELEFONE AS VARCHAR(14)
    CONSTRAINT formato_telefone CHECK(VALUE ~ '^\(\d{2}\)\d?\d{4}-\d{4}$');
CREATE DOMAIN D_CEP AS CHAR(10)
    CONSTRAINT formato_cep CHECK(VALUE ~ '^\d{2}\.\d{3}-\d{3}$');
CREATE DOMAIN D_ESTADO AS CHAR(2)
    CONSTRAINT formato_estado CHECK(VALUE ~ '^[A-Z]{2}$');
CREATE DOMAIN D_NUMERO AS VARCHAR(10)
    CONSTRAINT formato_numero CHECK(VALUE ~ '^([1-9]\d{1,9})|(S/N)$');
CREATE DOMAIN D_PLACA AS CHAR(8)
    CONSTRAINT formato_placa CHECK(VALUE ~ '^[A-Z]{3}-\d{4}$');
CREATE DOMAIN D_CPF AS CHAR(14)
    CONSTRAINT formato_cpf CHECK(VALUE ~ '^\d{3}\.\d{3}\.\d{3}-\d{2}$');
CREATE DOMAIN D_CNPJ AS CHAR(18)
    CONSTRAINT formato_cnpj CHECK(VALUE ~ '^\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}$');

CREATE DOMAIN D_NOME AS VARCHAR(255);
CREATE DOMAIN D_CIDADE AS VARCHAR(255);
CREATE DOMAIN D_BAIRRO AS VARCHAR(255);
CREATE DOMAIN D_LOGRADOURO AS VARCHAR(255);
CREATE DOMAIN D_CNH AS VARCHAR(20);
CREATE DOMAIN D_RG AS VARCHAR(20);
CREATE DOMAIN D_MARCA AS VARCHAR(45);
CREATE DOMAIN D_MODELO AS VARCHAR(45);
CREATE DOMAIN D_PRODUTO AS VARCHAR(255);
CREATE DOMAIN D_PESO AS DECIMAL(20,3);
CREATE DOMAIN D_PRECO AS DECIMAL(20,2);

-- -----------------------------------------------------
-- Tabela cliente
-- -----------------------------------------------------
CREATE TABLE cliente (
    id SERIAL,
    cnpj D_CNPJ NOT NULL,
    nome D_NOME NOT NULL,
    telefone1 D_TELEFONE NULL,
    telefone2 D_TELEFONE NULL,

    PRIMARY KEY (id),
    CONSTRAINT unique_cnpj UNIQUE(cnpj)
);

-- -----------------------------------------------------
-- Tabela endereco
-- -----------------------------------------------------
CREATE TABLE endereco (
    id SERIAL,
    cep D_CEP NOT NULL,
    estado D_ESTADO NOT NULL,
    cidade D_CIDADE NOT NULL,
    bairro D_BAIRRO NOT NULL,
    logradouro D_LOGRADOURO NOT NULL,
    numero D_NUMERO NOT NULL,
    ponto_referencia TEXT NULL,

    PRIMARY KEY (id),
    CONSTRAINT unique_endereco
        UNIQUE(cep, estado, cidade, bairro, logradouro, numero)
);

-- -----------------------------------------------------
-- Tabela motorista
-- -----------------------------------------------------
CREATE TABLE motorista (
    id SERIAL,
    cpf D_CPF NOT NULL,
    nome D_NOME NOT NULL,
    cnh D_CNH NOT NULL,
    rg D_RG NOT NULL,
    telefone1 D_TELEFONE NULL,
    telefone2 D_TELEFONE NULL,
    disponivel BOOLEAN NOT NULL,

    PRIMARY KEY (id),
    CONSTRAINT unique_cpf UNIQUE(cpf),
    CONSTRAINT unique_cnh UNIQUE(cnh),
    CONSTRAINT unique_rg UNIQUE(rg)
);

-- -----------------------------------------------------
-- Tabela veiculo
-- -----------------------------------------------------
CREATE TABLE veiculo (
    id SERIAL,
    placa D_PLACA NOT NULL,
    marca D_MARCA NOT NULL,
    modelo D_MODELO NOT NULL,

    PRIMARY KEY (id),
    CONSTRAINT unique_placa UNIQUE(placa)
);

-- -----------------------------------------------------
-- Tabela pedido
-- -----------------------------------------------------
CREATE TABLE pedido (
    id SERIAL,
    produto D_PRODUTO NOT NULL,
    momento_pedido TIMESTAMP NOT NULL,
    situacao STATUS_PEDIDO NOT NULL,
    qtd_volumes INT NULL,
    peso_liquido D_PESO NULL,
    preco_frete D_PRECO NULL,
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
-- Tabela viagem
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
-- Tabela carga
-- -----------------------------------------------------
CREATE TABLE carga (
    pedido_id INT NOT NULL,
    viagem_id INT NOT NULL,
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
-- Tabela motorista_veiculo
-- -----------------------------------------------------
CREATE TABLE motorista_veiculo (
    id SERIAL,
    veiculo_id INT NOT NULL,
    motorista_id INT NOT NULL,
    momento_alocacao TIMESTAMP NULL,
    momento_liberacao TIMESTAMP NULL,

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
