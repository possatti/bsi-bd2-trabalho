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

-- A função será usada na trigger da view REGISTRO_CLIENTE. Ela
-- intercepta todos os comandos exceto o SELECT para realizar as
-- operações adequadamente em cada tabela que é usada na view.
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
            VALUES (NEW.CNPJ, NEW.NOME, NEW.TELEFONE, NEW.ENDERECO_ID, id_endereco);

            RETURN NEW;

        -- Se a operação for um update, atualizamos os dados nas tabelas adequadas.
        ELSIF (TG_OP = 'UPDATE') THEN
            -- Busca pelo id do cliente e do seu endereço.
            SELECT ID, ENDERECO_ID
            INTO id_cliente, id_endereco
            FROM CLIENTE
            WHERE CPF = OLD.CPF;

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
            WHERE CPF = OLD.CPF;

            -- Apaga o registro do cliente.
            DELETE FROM CLIENTE
            WHERE OLD.ID = id_cliente;

            -- Apaga o registro do endereço.
            DELETE FROM ENDERECO
            WHERE OLD.ENDERECO_ID = id_endereco;

            RETURN OLD;
        END IF;
    END;
$iud_registro_cliente$ LANGUAGE plpgsql;

-- Trigger para a view REGISTRO_CLIENTE. Ela é usada para
-- interceptar os comando de INSERT, UPDATE e DELETE.
CREATE TRIGGER IUD_REGISTRO_CLIENTE
    INSTEAD OF INSERT OR UPDATE OR DELETE ON REGISTRO_CLIENTE
    FOR EACH ROW EXECUTE PROCEDURE iud_registro_cliente();
