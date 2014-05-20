--
-- Este usuário é responsável pelas atividades relacionadas à operação da empresa,
-- como criação de pedidos, cadastro de clientes, criação de viagens, associação
-- de um motorista à um veículo, ou seja, tudo relacionado ao departamento
-- operacional da empresa.
--

CREATE ROLE operacional WITH LOGIN PASSWORD 'operacional123';

GRANT SELECT, INSERT, UPDATE
ON TABLE REGISTRO_CLIENTE, CLIENTE, MOTORISTAS_DISPONIVEIS, PEDIDO, VIAGEM, ENDERECO
TO operacional;
GRANT SELECT (ID, DISPONIVEL, VEICULO_ID), UPDATE (DISPONIVEL, VEICULO_ID) ON TABLE MOTORISTA TO operacional;
GRANT SELECT ON TABLE VEICULO TO operacional;
GRANT SELECT ON TABLE pedido_id_seq, cliente_id_seq, viagem_id_seq, endereco_id_seq TO operacional;

--
-- Este usuário é responsável pelas atividades relacionadas ao departamento 
-- pessoal da empresa, logo, atividades como cadastro, atualização e remoção de
-- motoristas está em sua competência.
--

CREATE ROLE rh WITH LOGIN PASSWORD 'rh123';

GRANT SELECT, INSERT, UPDATE, DELETE
ON TABLE MOTORISTA TO rh;
GRANT SELECT ON TABLE VIAGEM TO rh;