-- ----------------------------------------------------------
-- Esta SP retorna uma tabela com todos os pedidos que uma
-- determinada viagem contribuiu ou está contribuindo para.
-- 
-- Argumentos:
--      id_viagem: id da viagem.
-- ----------------------------------------------------------
CREATE FUNCTION pedidos_da_viagem(id_viagem INT)
RETURNS TABLE(
    id INT,
    produto D_PRODUTO,
    momento_pedido TIMESTAMP,
    situacao STATUS_PEDIDO,
    qtd_volumes INT,
    peso_liquido D_PESO,
    preco_frete D_PRECO,
    observacoes TEXT,
    cliente_id INT,
    endereco_origem_id INT,
    endereco_destino_id INT
    )
AS $$
    BEGIN
        RETURN QUERY
            SELECT *
            FROM pedido p
            WHERE p.id = ANY (
                SELECT c.pedido_id
                FROM carga c
                WHERE viagem_id = id_viagem
            );
    END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------
-- Seleciona todos os pedidos de um determinado cliente
-- ordenando pelos mais recentes.
-- 
-- Argumentos:
--      id_viagem: id da viagem.
-- ----------------------------------------------------------
CREATE FUNCTION pedidos_do_cliente(id_cliente INT)
RETURNS TABLE(
    id INT,
    produto D_PRODUTO,
    momento_pedido TIMESTAMP,
    situacao STATUS_PEDIDO,
    qtd_volumes INT,
    peso_liquido D_PESO,
    preco_frete D_PRECO,
    observacoes TEXT,
    cliente_id INT,
    endereco_origem_id INT,
    endereco_destino_id INT
    )
AS $$
    BEGIN
        RETURN QUERY
            SELECT *
            FROM pedido p
            WHERE p.cliente_id = id_cliente
            ORDER BY momento_pedido;
    END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------
-- Elabora uma tabela com um relatório mensal de pedidos. O
-- relatório é um resumo de cada pedido feito em um
-- determinado mês.
--
-- Argumentos:
--      mes: mês dos pedidos a serem selecionados.
--      ano: ano dos pedidos a serem selecionados.
-- ----------------------------------------------------------
CREATE FUNCTION relatorio_mensal_pedidos(mes INT, ano INT)
RETURNS TABLE(
    nome_cliente D_NOME,
    produto D_PRODUTO,
    qtd_volumes INT,
    peso_encomenda D_PESO,
    preco_frete D_PRECO,
    status STATUS_PEDIDO,
    data_requisicao TIMESTAMP)
AS $$
    BEGIN
        RETURN QUERY
            SELECT
                c.nome, p.produto, p.qtd_volumes, p.peso_encomenda,
                p.preco_frete, p.status, p.timestamp_requisicao
            FROM pedido p
            INNER JOIN cliente c ON p.cliente_id = c.id
            WHERE
                EXTRACT(YEAR FROM p.timestamp_requisicao) = ano
                AND EXTRACT(MONTH FROM p.timestamp_requisicao) = mes;
    END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------
-- Calcula o tempo de duração médio das viagens por mês. Isto
-- é, calcula o tempo médio gasto em que os veículos estão na
-- estrada.
-- 
-- Por ser mensal, é necessário um critério para a seleção.
-- Para isso a SP seleciona apenas as viagens que terminaram
-- no mês indicado.
-- 
-- Argumentos:
--      mes: mês em que os veículos terminaram a entrega.
--      ano: ano em que os veículos terminaram a entrega.
-- ----------------------------------------------------------
CREATE FUNCTION duracao_media_mensal_viagens(mes INT, ano INT)
RETURNS INTERVAL
AS $$
    DECLARE
        media_tempo INTERVAL;
    BEGIN
        -- Captura a média para a variável media_tempo.
        SELECT
            avg(age(v.timestamp_inicio, v.timestamp_fim))
        INTO media_tempo
        FROM viagem v
        WHERE
            EXTRACT(YEAR FROM v.momento_saida) = ano
            AND EXTRACT(MONTH FROM v.momento_chegada) = mes;

        -- Retorna a média
        RETURN media_tempo;
    END;
$$ LANGUAGE plpgsql;
