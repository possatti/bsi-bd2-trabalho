--
-- Mantém os campos QTD_VOLUMES e PESO_ENCOMENDA atualizados na tabela PEDIDO.
--
CREATE FUNCTION attr_redundante_qtd_vol_peso_encomenda()
RETURNS trigger AS 
$$
    BEGIN
        IF (TG_OP = 'INSERT') THEN
            UPDATE PEDIDO
            SET (QTD_VOLUMES, PESO_ENCOMENDA) = (QTD_VOLUMES + NEW.QTD_VOLUMES, PESO_ENCOMENDA + NEW.PESO_VOLUMES)
            WHERE ID = NEW.PEDIDO_ID;
            RETURN NEW;
        ELSIF (TG_OP = 'UPDATE') THEN
            UPDATE PEDIDO
            SET (QTD_VOLUMES, PESO_ENCOMENDA) = (QTD_VOLUMES + NEW.QTD_VOLUMES - OLD.QTD_VOLUMES, PESO_ENCOMENDA + NEW.PESO_VOLUMES - OLD.PESO_VOLUMES)
            WHERE ID = NEW.PEDIDO_ID;
            RETURN NEW;
        ELSIF (TG_OP = 'DELETE') THEN
            UPDATE PEDIDO
            SET (QTD_VOLUMES, PESO_ENCOMENDA) = (QTD_VOLUMES - OLD.QTD_VOLUMES, PESO_ENCOMENDA - OLD.PESO_VOLUMES)
            WHERE ID = OLD.PEDIDO_ID;
            RETURN OLD;
        END IF;
        RETURN NULL;

    END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER attr_redundante_qtd_vol_peso_encomenda_tgr BEFORE INSERT OR UPDATE OF QTD_VOLUMES, PESO_VOLUMES OR DELETE ON VIAGEM
FOR EACH ROW
EXECUTE PROCEDURE attr_redundante_qtd_vol_peso_encomenda();

--
-- Essa SP garante o estado disponivel do motorista pra alterações na mesma tabela.
--
CREATE FUNCTION assert_motorista_disponivel_motorista()
RETURNS trigger AS 
$$
    BEGIN
        IF (TG_OP = 'INSERT') THEN
            IF (NEW.VEICULO_ID IS NOT NULL) THEN
                NEW.DISPONIVEL := true;
            END IF;
            RETURN NEW;
        ELSIF (TG_OP = 'UPDATE') THEN
            IF (OLD.VEICULO_ID IS NULL AND NEW.VEICULO_ID IS NOT NULL) THEN
                IF (NOT EXISTS (SELECT * FROM VIAGEM WHERE MOTORISTA_ID = NEW.ID AND TIMESTAMP_FIM IS NULL)) THEN
                    NEW.DISPONIVEL := true;
                ELSE
                    NEW.DISPONIVEL := false;
                END IF;
            END IF;
            RETURN NEW;
        END IF;
        RETURN NULL;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER assert_motorista_disponivel_motorista BEFORE INSERT OR UPDATE OF DISPONIVEL, VEICULO_ID ON MOTORISTA
FOR EACH ROW
EXECUTE PROCEDURE assert_motorista_disponivel_motorista();

--
-- Essa SP serve para garantir que uma viagem não tenha um motorista indisponível,
-- além de atualizar o STATUS do motorista conforme as associações.
--
CREATE FUNCTION assert_motorista_diponivel_viagem()
RETURNS trigger AS 
$$
    DECLARE
        motorista_disponivel BOOLEAN;
    BEGIN
        IF (TG_OP = 'INSERT') THEN
            SELECT DISPONIVEL INTO motorista_disponivel
            FROM MOTORISTA
            WHERE MOTORISTA.ID = NEW.MOTORISTA_ID;
            
            IF NOT motorista_disponivel THEN
                RAISE EXCEPTION 'Motorista não disponivel!';
            ELSE
                UPDATE MOTORISTA
                SET DISPONIVEL = false
                WHERE ID = NEW.MOTORISTA_ID;
            END IF;

            IF NEW.TIMESTAMP_FIM IS NOT NULL THEN
                UPDATE MOTORISTA
                SET DISPONIVEL = true
                WHERE ID = NEW.MOTORISTA_ID;
            END IF;

            RETURN NEW;
        ELSIF (TG_OP = 'UPDATE') THEN
            SELECT DISPONIVEL INTO motorista_disponivel
            FROM MOTORISTA
            WHERE MOTORISTA.ID = NEW.MOTORISTA_ID;
            
            IF (NEW.MOTORISTA_ID != OLD.MOTORISTA_ID) THEN
                IF NOT motorista_disponivel THEN
                    RAISE EXCEPTION 'Motorista não disponivel!';
                ELSE
                    UPDATE MOTORISTA
                    SET DISPONIVEL = false
                    WHERE ID = NEW.MOTORISTA_ID;
                    
                    UPDATE MOTORISTA
                    SET DISPONIVEL = true
                    WHERE ID = OLD.MOTORISTA_ID;
                END IF;
            END IF;
            IF (OLD.TIMESTAMP_FIM IS NULL AND NEW.TIMESTAMP_FIM IS NOT NULL) THEN
                UPDATE MOTORISTA
                SET DISPONIVEL = true
                WHERE ID = NEW.MOTORISTA_ID;
            END IF;
            IF (NEW.TIMESTAMP_FIM IS NULL) THEN
                RAISE EXCEPTION 'Não se pode apagar uma data de fim de viagem!';
            END IF;

            RETURN NEW;
        ELSIF (TG_OP = 'DELETE') THEN
            UPDATE MOTORISTA
            SET DISPONIVEL = true
            WHERE ID = OLD.MOTORISTA_ID;
            RETURN OLD;
        END IF;

        RETURN NULL;
    END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER assert_motorista_diponivel_viagem_tgr BEFORE INSERT OR UPDATE OF MOTORISTA_ID, TIMESTAMP_FIM OR DELETE ON VIAGEM
FOR EACH ROW
EXECUTE PROCEDURE assert_motorista_diponivel_viagem();

--
-- Checa as restrições de integridade confore a alteração no status do pedido.
--
CREATE FUNCTION check_status_pedido()
RETURNS trigger AS
$$
    BEGIN
        IF (NEW.STATUS LIKE 'ENVIADO') THEN
            IF (NOT EXISTS (SELECT * FROM VIAGEM WHERE PEDIDO_ID = NEW.ID AND TIMESTAMP_FIM IS NULL) OR EXISTS (SELECT * FROM VIAGEM WHERE PEDIDO_ID = NEW.ID AND TIMESTAMP_FIM IS NOT NULL)) THEN
                RAISE EXCEPTION 'Não existem viagens associadas a este pedido.';
            END IF;
        ELSIF (NEW.STATUS LIKE 'EM_PROCESSAMENTO') THEN
            RAISE EXCEPTION 'Não se pode alterar o estado para EM_PROCESSAMENTO.';
        ELSIF (OLD.STATUS NOT LIKE 'EM_PROCESSAMENTO' AND NEW.STATUS LIKE 'EM_SEPARACAO') THEN
            RAISE EXCEPTION 'Não se pode alterar o estado para EM_SEPARACAO.';
        ELSIF (NEW.STATUS LIKE 'RECEBIDO') THEN
            IF (EXISTS (SELECT * FROM VIAGEM WHERE PEDIDO_ID = NEW.ID AND TIMESTAMP_FIM IS NULL) OR NOT EXISTS (SELECT * FROM VIAGEM WHERE PEDIDO_ID = NEW.ID AND TIMESTAMP_FIM IS NOT NULL)) THEN
                RAISE EXCEPTION 'Existem viagens que não foram concluídas ainda.';
            END IF;
        END IF;
        RETURN NEW;
    END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER check_status_pedido_tgr BEFORE UPDATE OF STATUS ON PEDIDO
FOR EACH ROW
EXECUTE PROCEDURE check_status_pedido();

--
-- A função será usada na trigger da view REGISTRO_CLIENTE. Ela
-- intercepta todos os comandos exceto o SELECT para realizar as
-- operações adequadamente em cada tabela que é usada na view.
--
CREATE FUNCTION iud_registro_cliente()
    RETURNS trigger AS $iud_registro_cliente$

    DECLARE
    id_endereco BIGINT;
    id_cliente BIGINT;

    BEGIN
        -- Se a operação for de inserção, inserimos os dados nas tabelas adequadas.
        IF (TG_OP = 'INSERT') THEN
            -- Obtém o valor do próximo id que deverá ser usado.
            id_endereco := nextval('endereco_id_seq');

            -- Insere o endereço.
            INSERT INTO ENDERECO(ID, CEP, ESTADO, CIDADE, BAIRRO, LOGRADOURO, NUMERO, PTO_REFERENCIA)
            VALUES (id_endereco, NEW.CEP, NEW.ESTADO, NEW.CIDADE, NEW.BAIRRO,
                NEW.LOGRADOURO, NEW.NUMERO, NEW.PTO_REFERENCIA);


            -- Insere o cliente, usando o valor de id do endereço para referencia-lo.
            INSERT INTO CLIENTE
            VALUES (NEXTVAL('cliente_id_seq'), NEW.CNPJ, NEW.NOME, NEW.TELEFONE, id_endereco);

            RETURN NEW;

        -- Se a operação for um update, atualizamos os dados nas tabelas adequadas.
        ELSIF (TG_OP = 'UPDATE') THEN
            -- Busca pelo id do cliente e do seu endereço.
            SELECT ID, ENDERECO_ID
            INTO id_cliente, id_endereco
            FROM CLIENTE
            WHERE CNPJ LIKE OLD.CNPJ;

            -- Atualiza os dados do cliente.
            UPDATE CLIENTE
            SET (CNPJ, NOME, TELEFONE) =
                (NEW.CNPJ, NEW.NOME, NEW.TELEFONE)
            WHERE ID = id_cliente;

            -- Atualiza os dados do endereço.
            UPDATE ENDERECO
            SET (CEP, ESTADO, CIDADE, BAIRRO, LOGRADOURO, NUMERO, PTO_REFERENCIA) =
                (NEW.CEP, NEW.ESTADO, NEW.CIDADE, NEW.BAIRRO, NEW.LOGRADOURO, NEW.NUMERO, NEW.PTO_REFERENCIA)
            WHERE ID = id_endereco;

            RETURN NEW;

        -- Se a operação for de deleção, apagamos os registros do respectivo cliente e endereço.
        ELSIF (TG_OP = 'DELETE') THEN
            -- Busca pelo id do cliente e do seu endereço.
            SELECT ID, ENDERECO_ID
            INTO id_cliente, id_endereco
            FROM CLIENTE
            WHERE CNPJ LIKE OLD.CNPJ;

            -- Apaga o registro do cliente.
            DELETE FROM CLIENTE
            WHERE ID = id_cliente;

            -- Apaga o registro do endereço.
            DELETE FROM ENDERECO
            WHERE ID = id_endereco;

            RETURN OLD;
        END IF;
    END;
$iud_registro_cliente$ LANGUAGE plpgsql;
-- Trigger para a view REGISTRO_CLIENTE. Ela é usada para
-- interceptar os comando de INSERT, UPDATE e DELETE.
CREATE TRIGGER IUD_REGISTRO_CLIENTE
    INSTEAD OF INSERT OR UPDATE OR DELETE ON REGISTRO_CLIENTE
    FOR EACH ROW EXECUTE PROCEDURE iud_registro_cliente();
