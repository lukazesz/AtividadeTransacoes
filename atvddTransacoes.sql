-- 
-- TRABALHO: TRANSAÇÕES E NÍVEIS DE ISOLAMENTO - POSTGRESQL
-- Modelo relacional: LOJA
--
-- IMPORTANTE:
-- 1) Execute a PARTE 1 apenas uma vez.
-- 2) Os exercícios 7, 8 e 9 usam DUAS JANELAS/SESSÕES.
-- 3) Quando aparecer "SESSÃO 1" ou "SESSÃO 2", execute
--    aquele bloco na janela correspondente.
-- 4) Não execute BEGIN/SET novamente no meio da mesma transação.
--
-- PARTE 1 - CRIAÇÃO DO BANCO / TABELAS / DADOS
-- EXECUTE UMA VEZ
--

CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100),
    cidade VARCHAR(100)
);

CREATE TABLE produtos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100),
    preco NUMERIC(10,2),
    estoque INT
);

CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INT REFERENCES clientes(id),
    produto_id INT REFERENCES produtos(id),
    quantidade INT
);


INSERT INTO clientes (nome, cidade) VALUES
('Ana', 'João Pessoa'),
('Lucas', 'Guarabira'),
('Bruna', 'Campina Grande');

INSERT INTO produtos (nome, preco, estoque) VALUES
('Notebook', 3000.00, 10),
('Mouse', 100.00, 20),
('Teclado', 200.00, 15);


-- Conferir o banco
SELECT * FROM clientes;
SELECT * FROM produtos;
SELECT * FROM pedidos;

