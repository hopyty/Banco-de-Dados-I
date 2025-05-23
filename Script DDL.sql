
CREATE TABLE Usuario (
    id_usuario SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(100) NOT NULL
);


CREATE TABLE Conta (
    id_conta SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL,
    nome_banco VARCHAR(100),
    tipo_conta VARCHAR(50),
    saldo_inicial NUMERIC(12, 2) DEFAULT 0,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE
);


CREATE TABLE Categoria (
    id_categoria SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo VARCHAR(10) CHECK (tipo IN ('receita', 'despesa')) NOT NULL
);


CREATE TABLE Transacao (
    id_transacao SERIAL PRIMARY KEY,
    id_conta INT NOT NULL,
    id_categoria INT NOT NULL,
    data DATE NOT NULL,
    valor NUMERIC(12, 2) NOT NULL,
    descricao TEXT,
    tipo VARCHAR(10) CHECK (tipo IN ('receita', 'despesa')) NOT NULL,
    FOREIGN KEY (id_conta) REFERENCES Conta(id_conta) ON DELETE CASCADE,
    FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria)
);


CREATE TABLE Orcamento (
    id_orcamento SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_categoria INT NOT NULL,
    mes INT CHECK (mes BETWEEN 1 AND 12),
    ano INT,
    valor_limite NUMERIC(12, 2),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria)
);


CREATE TABLE MetaFinanceira (
    id_meta SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    valor_objetivo NUMERIC(12, 2),
    data_limite DATE,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE
);


CREATE TABLE Parcela (
    id_transacao INT NOT NULL,
    n_parcela INT NOT NULL,
    valor_parcela NUMERIC(12, 2),
    data_vencimento DATE,
    PRIMARY KEY (id_transacao, n_parcela),
    FOREIGN KEY (id_transacao) REFERENCES Transacao(id_transacao) ON DELETE CASCADE
);
