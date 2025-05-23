CREATE OR REPLACE VIEW total_receitas_despesas_por_categoria AS
SELECT 
    c.nome AS categoria,
    c.tipo,
    SUM(t.valor) AS total_valor
FROM 
    Transacao t
JOIN 
    Categoria c ON t.id_categoria = c.id_categoria
GROUP BY 
    c.nome, c.tipo
ORDER BY 
    c.tipo, total_valor DESC;


CREATE OR REPLACE VIEW saldo_mensal_por_conta AS
SELECT 
    a.id_conta,
    a.nome AS conta,
    DATE_TRUNC('month', t.data) AS mes_ano,
    SUM(CASE WHEN c.tipo = 'receita' THEN t.valor ELSE 0 END) AS total_receitas,
    SUM(CASE WHEN c.tipo = 'despesa' THEN t.valor ELSE 0 END) AS total_despesas,
    SUM(CASE WHEN c.tipo = 'receita' THEN t.valor ELSE -t.valor END) AS saldo
FROM 
    Transacao t
JOIN 
    Conta a ON t.id_conta = a.id_conta
JOIN 
    Categoria c ON t.id_categoria = c.id_categoria
GROUP BY 
    a.id_conta, a.nome, mes_ano
ORDER BY 
    a.id_conta, mes_ano;

CREATE OR REPLACE VIEW despesas_por_mes_e_categoria AS
SELECT 
    DATE_TRUNC('month', t.data) AS mes_ano,
    c.nome AS categoria,
    SUM(t.valor) AS total_despesas
FROM 
    Transacao t
JOIN 
    Categoria c ON t.id_categoria = c.id_categoria
WHERE 
    c.tipo = 'despesa'
GROUP BY 
    mes_ano, c.nome
ORDER BY 
    mes_ano DESC, total_despesas DESC;
