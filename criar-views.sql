-- ----------------------------------------------------------
-- Esta view exibe os dados básicos dos motoristas que estão
-- disponíveis no momento. Ela será utilizada para que seja
-- possível detectar com facilidade os motoristas que já não
-- estão ocupados e, portanto, podem realizar novos serviços.
-- ----------------------------------------------------------
CREATE VIEW motoristas_disponiveis
AS
    SELECT m.cpf, m.nome, m.telefone1, m.telefone2
    FROM motorista m
    WHERE disponivel = true;


-- ----------------------------------------------------------
-- Esta view exibe os clientes, porém, ordenados quanto aos
-- que mais já fizeram pedidos.
-- ----------------------------------------------------------
CREATE VIEW clientes_frequentes
AS
    SELECT c.cnpj, c.nome, c.telefone1, c.telefone2,
        COUNT(p.id) AS qtd_pedidos
    FROM cliente c
        INNER JOIN pedido p ON c.id = p.cliente_id
    GROUP BY c.cnpj, c.nome, c.telefone1, c.telefone2
    ORDER BY qtd_pedidos;

-- ----------------------------------------------------------
-- Exibe todos os veículos que estão ociosos no momento atual.
-- ----------------------------------------------------------
CREATE VIEW veiculos_ociosos
AS
    SELECT ve.placa, ve.marca, ve.modelo
    FROM veiculo ve
    WHERE ve.id = ANY (
        SELECT vi.veiculo_id
        FROM viagem vi
        WHERE momento_chegada = NULL
    );
