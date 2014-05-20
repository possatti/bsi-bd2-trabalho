--
-- Filtra a tabela de pedidos, selecionando apenas os pedidos pertencentes
-- a um determinado cliente.
-- 
-- Argumentos:
--      cnpj_cliente: cnpj do cliente.
--
CREATE FUNCTION pedidos_por_cliente(cnpj_cliente CHAR(18))
RETURNS TABLE(
    DATA_REQUISICAO TIMESTAMP,
    PRODUTO VARCHAR(255), QTD_VOLUMES INT, PESO_ENCOMENDA INT,
    DISTANCIA INT, PRECO_FRETE DECIMAL(10,2), OBSERVACOES VARCHAR(255),
    STATUS VARCHAR(20))
AS $$
    BEGIN
        RETURN QUERY
            SELECT
                P.TIMESTAMP_REQUISICAO, P.PRODUTO, P.QTD_VOLUMES,
                P.PESO_ENCOMENDA, P.DISTANCIA, P.PRECO_FRETE,
                P.OBSERVACOES, P.STATUS
            FROM PEDIDO P
            INNER JOIN CLIENTE C ON P.CLIENTE_ID = C.ID
            WHERE C.CNPJ = cnpj_cliente;
    END;
$$ LANGUAGE plpgsql;

--
-- Elabora uma tabela com um relatório mensal de pedidos. O relatório é um
-- resumo de cada pedido feito em um determinado mês.
--
-- Argumentos:
--      mes: mês dos pedidos a serem selecionados.
--      ano: ano dos pedidos a serem selecionados.
--
CREATE FUNCTION relatorio_mensal_pedidos(mes INT, ano INT)
RETURNS TABLE(
    NOME_CLIENTE VARCHAR(255),
    PRODUTO VARCHAR(255),
    QTD_VOLUMES INT,
    PESO_ENCOMENDA INT,
    PRECO_FRETE DECIMAL(10,2),
    STATUS VARCHAR(20),
    DATA_REQUISICAO TIMESTAMP)
AS $$
    BEGIN
        RETURN QUERY
            SELECT
                C.NOME, P.PRODUTO, P.QTD_VOLUMES, P.PESO_ENCOMENDA,
                P.PRECO_FRETE, P.STATUS, P.TIMESTAMP_REQUISICAO
            FROM PEDIDO P
            INNER JOIN CLIENTE C ON P.CLIENTE_ID = C.ID
            WHERE
                EXTRACT(YEAR FROM P.TIMESTAMP_REQUISICAO) = ano
                AND EXTRACT(MONTH FROM P.TIMESTAMP_REQUISICAO) = mes;
    END;
$$ LANGUAGE plpgsql;

--
-- Calcula o tempo de duração médio das viagens por mês. Isto é, calcula
-- o tempo gasto pelos veículos, em média, para alcançar o destino. Para
-- isso a SP seleciona apenas as viagens que terminaram no mês indicado.
--
-- Argumentos:
--      mes: mês em que os veículos terminaram a entrega.
--      ano: ano em que os veículos terminaram a entrega.
--
CREATE FUNCTION duracao_media_mensal_viagens(mes INT, ano INT)
RETURNS INTERVAL
AS $$
    DECLARE
        media_tempo INTERVAL;
    BEGIN
        SELECT
            avg(age(V.TIMESTAMP_INICIO, V.TIMESTAMP_FIM))
        INTO media_tempo
        FROM VIAGEM V
        WHERE
            EXTRACT(YEAR FROM V.TIMESTAMP_FIM) = ano
            AND EXTRACT(MONTH FROM V.TIMESTAMP_FIM) = mes;
        RETURN media_tempo;
    END;
$$ LANGUAGE plpgsql;
