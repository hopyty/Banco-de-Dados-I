SELECT  c.nome              AS categoria,
        SUM(t.valor)        AS total_despesas
FROM            USUARIO u
JOIN            CONTA   ct  ON ct.id_usuario   = u.id_usuario
JOIN            TRANSACAO t ON t.id_conta      = ct.id_conta
JOIN            CATEGORIA c ON c.id_categoria  = t.id_categoria
WHERE   u.id_usuario        = :p_id_usuario   
  AND   t.tipo              = 'DESPESA'
  AND   MONTH(t.data)       = :p_mes
  AND   YEAR(t.data)        = :p_ano
GROUP BY c.nome
ORDER BY total_despesas DESC;
SELECT  ct.id_conta,
        ct.nome_banco,
        ct.tipo_conta,
        ct.saldo_inicial 
        + COALESCE(SUM(
            CASE WHEN t.tipo = 'RECEITA'  THEN  t.valor
                 WHEN t.tipo = 'DESPESA'  THEN -t.valor
            END
          ),0)             AS saldo_atual
FROM    CONTA      ct
LEFT JOIN TRANSACAO t  ON t.id_conta = ct.id_conta
WHERE   ct.id_usuario   = :p_id_usuario
GROUP BY ct.id_conta, ct.nome_banco, ct.tipo_conta, ct.saldo_inicial
ORDER BY saldo_atual DESC;
SELECT  c.nome                     AS categoria,
        o.valor_limite,
        SUM(t.valor)               AS gasto_no_mes
FROM            ORCAMENTO  o
JOIN            CATEGORIA  c  ON c.id_categoria  = o.id_categoria
LEFT JOIN       USUARIO    u  ON u.id_usuario    = o.id_usuario
LEFT JOIN       CONTA      ct ON ct.id_usuario   = u.id_usuario
LEFT JOIN       TRANSACAO  t  ON t.id_conta      = ct.id_conta
                              AND t.id_categoria = c.id_categoria
                              AND MONTH(t.data)  = o.mes
                              AND YEAR(t.data)   = o.ano
                              AND t.tipo         = 'DESPESA'
WHERE o.id_usuario = :p_id_usuario
GROUP BY c.nome, o.valor_limite
HAVING SUM(t.valor) > o.valor_limite;
SELECT  u.id_usuario, u.nome, u.email
FROM    USUARIO u
WHERE  NOT EXISTS (
        SELECT 1
        FROM   CONTA      ct
        JOIN   TRANSACAO  t ON t.id_conta = ct.id_conta
        WHERE  ct.id_usuario = u.id_usuario
          AND  t.data >= DATEADD(DAY,-30, CURRENT_DATE)
);
SELECT  u.id_usuario,
        u.nome,
        SUM(t.valor) AS total_despesas_2025
FROM            USUARIO  u
JOIN            CONTA    ct ON ct.id_usuario = u.id_usuario
JOIN            TRANSACAO t ON t.id_conta    = ct.id_conta
WHERE   t.tipo = 'DESPESA'
  AND   YEAR(t.data) = 2025
GROUP BY u.id_usuario, u.nome
ORDER BY total_despesas_2025 DESC
LIMIT 5;   
SELECT  t.id_transacao,
        t.descricao,
        p.n_parcela,
        p.valor_parcela,
        p.data_vencimento
FROM        TRANSACAO t
JOIN        PARCELA   p ON p.id_transacao = t.id_transacao
WHERE       p.data_vencimento > CURRENT_DATE;  
SELECT  YEAR(t.data)  AS ano,
        MONTH(t.data) AS mes,
        t.tipo,
        COUNT(*)      AS qtde_transacoes,
        SUM(t.valor)  AS total
FROM    TRANSACAO t
GROUP BY YEAR(t.data), MONTH(t.data), t.tipo
ORDER BY ano DESC, mes DESC, t.tipo;
SELECT  mf.id_meta,
        mf.nome,
        mf.valor_objetivo,
        mf.data_limite,
        COALESCE((
            SELECT SUM(t.valor)
            FROM   CONTA     ct
            JOIN   TRANSACAO t ON t.id_conta = ct.id_conta
            WHERE  ct.id_usuario = mf.id_usuario
              AND  t.tipo        = 'RECEITA'
              AND  t.descricao  LIKE '%' || mf.nome || '%'
        ),0) AS valor_acumulado
FROM    META_FINANCEIRA mf
WHERE   mf.data_limite  <= DATEADD(DAY,30,CURRENT_DATE)
  AND   mf.valor_objetivo >
        COALESCE((
            SELECT SUM(t.valor)
            FROM   CONTA     ct
            JOIN   TRANSACAO t ON t.id_conta = ct.id_conta
            WHERE  ct.id_usuario = mf.id_usuario
              AND  t.tipo        = 'RECEITA'
              AND  t.descricao  LIKE '%' || mf.nome || '%'
        ),0);
SELECT  ct.id_conta,
        ct.nome_banco,
        t.data,
        COUNT(*) AS transacoes_acima_1000
FROM        CONTA      ct
JOIN        TRANSACAO  t ON t.id_conta = ct.id_conta
WHERE       t.valor > 1000
GROUP BY    ct.id_conta, ct.nome_banco, t.data
HAVING      COUNT(*) > 5;
SELECT  AVG(total_dia) AS media_diaria_7d
FROM (
    SELECT  DATE(t.data)        AS dia,
            SUM(t.valor)        AS total_dia
    FROM            CONTA ct
    JOIN            TRANSACAO t ON t.id_conta = ct.id_conta
    WHERE   ct.id_usuario       = :p_id_usuario
      AND   t.tipo              = 'DESPESA'
      AND   t.data >= DATEADD(DAY,-7, CURRENT_DATE)
    GROUP BY DATE(t.data)
) sub;
