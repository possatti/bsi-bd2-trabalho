-- |          Restrições de integridade
-- |-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- |   Nº   | Tipo          |       Restrição
-- |-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- |   001  | Identidade    | Um Cliente é identificado por seu CNPJ.
-- |   002  | Identidade    | Cada veículo possui uma placa única.
-- |   003  | Identidade    | Um motorista é identificado por seu CPF.
-- |   004  | Identidade    | O RG e a CNH de um motorista devem ser únicos.
-- |   005  | Identidade    | Um pedido é identificado por pela Data e Hora da requisição e pelo cliente que fez o pedido (TIMESTAMP_REQUISICAO, CLIENTE).
-- |   006  | Identidade    | Uma viagem é identificada pela sua Data e Hora planejada para seu início e pelo motorista que irá executá-la (TIMESTAMP_INICIO, MOTORISTA).
-- |   007  | Identidade    | Cada endereço é único, ainda que contenham os mesmos dados. O motivo disso é para que caso de mudança do endereço de uma entidade que tenha o mesmo endereço de uma outra entidade, não seja necessário realizar outro cadastro, mas apenas uma alteração nessa tabela.
-- |   008  | Referencial   | Cada motorista tem um único veículo de trabalho.
-- |   009  | Referencial   | Um motorista não precisa necessariamente estar associado a um veículo no momento de seu cadastro.
-- |   010  | Referencial   | Podem haver mais de um motorista associado a um veículo.
-- |   011  | Referencial   | Podem haver veículos que ainda não estão associados a qualquer motorista (estão ociosos).
-- |   012  | Referencial   | Cada Cliente tem um único endereço registrado. Da mesma forma para os Motoristas.
-- |   013  | Referencial   | Um pedido tem necessariamente associado a ele um endereço de origem e outro de destino.
-- |   014  | Referencial   | Um pedido tem necessariamente um cliente associado à ele. Caso o cliente não exista, ele deverá ser cadastrado.
-- |   015  | Referencial   | Para que um pedido seja cumprido, serão necessárias uma ou mais viagens. Logo o pedido está associado a um conjunto de viagens.
-- |   016  | Referencial   | Porém um pedido não precisa ter nenhuma viagem associada no momento de seu cadastro.
-- |   017  | Referencial   | Cada viagem está necessariamente associada a um único pedido.
-- |   018  | Referencial   | Cada viagem será feita por um único motorista, mas um motorista pode cumprir com várias viagens.
-- |   019  | Domínio       | Um motorista só pode realizar uma viagem se estiver disponível.
-- |   020  | Domínio       | Um motorista está indisponível se não tiver um veículo associado OU desde o momento em que ele é associado a uma viagem até que essa viagem termine (tenha o campo TIMESTAMP_FIM definido).
-- |   021  | Domínio       | Um pedido pode estar em um, e somente um, dos quatro estados a seguir: em PROCESSAMENTO (assim que é criado); EM SEPARAÇÃO (quando os funcionários começam a preparar os veículos para a viagem);  ENVIADO (quando todos os veículos partirem); RECEBIDO (quando todos os veículos deixarem a carga no destino).
-- |   022  | Domínio       | A quantidade de volumes e o peso de um pedido DEVEM ser a soma da quantidade de volumes e do peso de suas respectivas viagens associadas.
-- |   023  | Domínio       | Um motorista deve necessariamente possuir um telefone.
-- |   024  | Domínio       | Um cliente deve necessariamente possuir um telefone.
-- |-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE ENDERECO (
    ID SERIAL PRIMARY KEY,
    CEP CHAR(10) NOT NULL,
    ESTADO CHAR(2) NOT NULL,
    CIDADE VARCHAR(255) NOT NULL,
    BAIRRO VARCHAR(255) NOT NULL,
    LOGRADOURO VARCHAR(255) NOT NULL,
    NUMERO VARCHAR(10),
    PTO_REFERENCIA VARCHAR(255),

    CONSTRAINT formato_cep CHECK(cep ~ '^\d{2}\.\d{3}-\d{3}$'),
    CONSTRAINT formato_estado CHECK(estado ~ '^[A-Z]{2}$'),
    CONSTRAINT formato_numero CHECK(numero ~ '^([1-9]\d{1,9})|(S/N)$')
);

CREATE TABLE VEICULO (
    ID SERIAL PRIMARY KEY,
    PLACA CHAR(8) NOT NULL,
    MARCA VARCHAR(45) NOT NULL,
    MODELO VARCHAR(45) NOT NULL,

    CONSTRAINT unique_placa UNIQUE(placa),
    CONSTRAINT formato_placa CHECK(placa ~ '^[A-Z]{3}-\d{4}$')
);

CREATE TABLE MOTORISTA (
    ID SERIAL PRIMARY KEY,
    CPF CHAR(14) NOT NULL,
    NOME VARCHAR(255) NOT NULL,
    CNH VARCHAR(20) NOT NULL,
    RG VARCHAR(45) NOT NULL,
    TELEFONE VARCHAR(14) NOT NULL,
    DISPONIVEL BOOLEAN NOT NULL DEFAULT false,
    ENDERECO_ID INT NOT NULL REFERENCES endereco,
    VEICULO_ID INT REFERENCES veiculo,

    CONSTRAINT unique_cpf UNIQUE(cpf),
    CONSTRAINT unique_rg UNIQUE(rg),
    CONSTRAINT unique_motorista_endereco_id UNIQUE(endereco_id),

    CONSTRAINT formato_cpf CHECK(cpf ~ '^\d{3}\.\d{3}\.\d{3}-\d{2}$'),
    CONSTRAINT formato_telefone CHECK(telefone ~ '^\(\d{2}\)(\d)?\d{4}-\d{4}$')
);

CREATE TABLE CLIENTE (
    ID SERIAL PRIMARY KEY,
    CNPJ CHAR(18) NOT NULL UNIQUE,
    NOME VARCHAR(255) NOT NULL,
    TELEFONE VARCHAR(14) NOT NULL,
    ENDERECO_ID INT NOT NULL REFERENCES endereco,

    CONSTRAINT unique_cnpj UNIQUE(cnpj),
    CONSTRAINT unique_cliente_endereco_id UNIQUE(endereco_id),
    
    CONSTRAINT formato_cnpj CHECK(cnpj ~ '^\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}$'),
    CONSTRAINT formato_telefone CHECK(telefone ~ '^\(\d{2}\)(\d)?\d{4}-\d{4}$')
);

CREATE TABLE PEDIDO (
    ID SERIAL PRIMARY KEY,
    TIMESTAMP_REQUISICAO TIMESTAMP NOT NULL,
    PRODUTO VARCHAR(255) NOT NULL,
    QTD_VOLUMES INT NOT NULL DEFAULT 0,
    PESO_ENCOMENDA INT NOT NULL DEFAULT 0,
    DISTANCIA INT,
    PRECO_FRETE DECIMAL(10,2),
    OBSERVACOES VARCHAR(255),
    STATUS VARCHAR(20) NOT NULL DEFAULT 'EM_PROCESSAMENTO',
    CLIENTE_ID INT NOT NULL REFERENCES cliente,
    ENDERECO_ORIGEM INT NOT NULL REFERENCES endereco,
    ENDERECO_DESTINO INT NOT NULL REFERENCES endereco,

    CONSTRAINT uniques_cliente UNIQUE(timestamp_requisicao, cliente_id),

    CONSTRAINT enum_status
    CHECK (status LIKE 'EM_PROCESSAMENTO'
        OR status LIKE 'EM_SEPARACAO'
        OR status LIKE 'ENVIADO'
        OR status LIKE 'RECEBIDO'
        )
);

CREATE TABLE VIAGEM (
    ID SERIAL PRIMARY KEY,
    QTD_VOLUMES INT NOT NULL,
    PESO_VOLUMES INT NOT NULL,
    TIMESTAMP_INICIO TIMESTAMP NOT NULL,
    TIMESTAMP_FIM TIMESTAMP,
    OBSERVACOES VARCHAR(255),
    MOTORISTA_ID INT REFERENCES motorista,
    PEDIDO_ID INT REFERENCES pedido,

    CONSTRAINT uniques_viagem UNIQUE(timestamp_inicio, motorista_id),
    CONSTRAINT datas_inicio_fim CHECK((TIMESTAMP_INICIO < TIMESTAMP_FIM) OR (TIMESTAMP_FIM IS NULL))
);
