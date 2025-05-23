CREATE INDEX idx_transacao_data ON Transacao(data);


CREATE INDEX idx_transacao_id_categoria ON Transacao(id_categoria);


CREATE INDEX idx_transacao_conta_data ON Transacao(id_conta, data);
