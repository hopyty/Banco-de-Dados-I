CREATE OR REPLACE FUNCTION fn_valor_positivo() RETURNS trigger AS $$
BEGIN
    IF NEW.valor < 0 THEN
        NEW.valor := ABS(NEW.valor);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_valor_positivo
BEFORE INSERT OR UPDATE ON Transacao
FOR EACH ROW EXECUTE FUNCTION fn_valor_positivo();


ALTER TABLE Conta ADD COLUMN IF NOT EXISTS ultima_atualizacao TIMESTAMP;

CREATE OR REPLACE FUNCTION fn_update_ultima_atualizacao() RETURNS trigger AS $$
BEGIN
    NEW.ultima_atualizacao := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_ultima_atualizacao
BEFORE UPDATE ON Conta
FOR EACH ROW EXECUTE FUNCTION fn_update_ultima_atualizacao();


CREATE OR REPLACE FUNCTION fn_prevent_categoria_delete() RETURNS trigger AS $$
DECLARE
    transacoes_existem INTEGER;
BEGIN
    SELECT COUNT(*) INTO transacoes_existem FROM Transacao WHERE id_categoria = OLD.id_categoria;
    IF transacoes_existem > 0 THEN
        RAISE EXCEPTION 'Não é possível deletar categoria que possui transações associadas.';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_categoria_delete
BEFORE DELETE ON Categoria
FOR EACH ROW EXECUTE FUNCTION fn_prevent_categoria_delete();
