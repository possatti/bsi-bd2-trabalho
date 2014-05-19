-- Exibe os dados básicos dos motoristas que estão disponíveis
CREATE VIEW MOTORISTAS_DISPONIVEIS
AS
    SELECT ID, CPF, NOME, TELEFONE
    FROM MOTORISTA M
    WHERE DISPONIVEL = true;

-- Exibe os dados de registro dos clientes por completo,
-- incluindo até mesmo os dados do endereço.
CREATE VIEW REGISTRO_CLIENTE
AS
    SELECT C.CNPJ, C.NOME, C.TELEFONE,
        E.CEP, E.ESTADO, E.CIDADE, E.BAIRRO,
        E.LOGRADOURO, E.NUMERO, E.PTO_REFERENCIA
    FROM CLIENTE C
    INNER JOIN ENDERECO E ON C.ENDERECO_ID = E.ID;

-- Exibe os dados de registro dos motoristas por completo,
-- incluindo até mesmo os dados do endereço.
CREATE VIEW REGISTRO_MOTORISTA
AS
    SELECT M.CPF, M.NOME, M.CNH, M.RG, M.TELEFONE, M.DISPONIVEL,
        E.CEP, E.ESTADO, E.CIDADE, E.BAIRRO,
        E.LOGRADOURO, E.NUMERO, E.PTO_REFERENCIA
    FROM MOTORISTA M
    INNER JOIN ENDERECO E ON M.ENDERECO_ID = E.ID;
