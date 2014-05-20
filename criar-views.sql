-- Esta view exibe os dados básicos dos motoristas que estão
-- disponíveis no momento. Ela será utilizada para que seja
-- possível detectar com facilidade os motoristas que já não
-- estão ocupados e, portanto, podem realizar novos serviços.
CREATE VIEW MOTORISTAS_DISPONIVEIS
AS
    SELECT CPF, NOME, TELEFONE
    FROM MOTORISTA M
    WHERE DISPONIVEL = true;

-- Esta view reune todos os dados dos clientes em um lugar só,
-- para que seja mais fácil visualizar os seus cadastros. Pois no
-- modelo do banco de dados, os dados do endereço se encontram em
-- uma tabela separada dos dados gerais dos clientes.
-- 
-- Além disso, para que o cadastro, edição e deleção de clientes
-- fique mais simples, uma trigger será usada para tratar essas
-- operações em cima desta própria visão. Assim, quando for
-- necessário alguma operação nos dados de clientes, não será
-- necessário manipular as tabelas CLIENTE e ENDERECO diretamente.
CREATE VIEW REGISTRO_CLIENTE
AS
    SELECT C.CNPJ, C.NOME, C.TELEFONE,
        E.CEP, E.ESTADO, E.CIDADE, E.BAIRRO,
        E.LOGRADOURO, E.NUMERO, E.PTO_REFERENCIA
    FROM CLIENTE C
    INNER JOIN ENDERECO E ON C.ENDERECO_ID = E.ID;

-- Esta view reune todos os dados dos motoristas em um lugar só,
-- para que seja mais fácil visualizar os seus cadastros. Pois no
-- modelo do banco de dados, os dados do endereço do motorista 
-- se encontram em uma tabela separada dos dados gerais dos deles.
CREATE VIEW REGISTRO_MOTORISTA
AS
    SELECT M.CPF, M.NOME, M.CNH, M.RG, M.TELEFONE, M.DISPONIVEL,
        E.CEP, E.ESTADO, E.CIDADE, E.BAIRRO,
        E.LOGRADOURO, E.NUMERO, E.PTO_REFERENCIA
    FROM MOTORISTA M
    INNER JOIN ENDERECO E ON M.ENDERECO_ID = E.ID;
