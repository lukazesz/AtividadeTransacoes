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
-- Se as tabelas já existirem e você quiser começar do zero,
-- descomente as linhas abaixo:
-- DROP TABLE IF EXISTS pedidos;
-- DROP TABLE IF EXISTS produtos;
-- DROP TABLE IF EXISTS clientes;

CREATE TABLE IF NOT EXISTS clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100),
    cidade VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS produtos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100),
    preco NUMERIC(10,2),
    estoque INT
);

CREATE TABLE IF NOT EXISTS pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INT REFERENCES clientes(id),
    produto_id INT REFERENCES produtos(id),
    quantidade INT
);

INSERT INTO clientes (nome, cidade)
SELECT 'Ana', 'João Pessoa'
WHERE NOT EXISTS (SELECT 1 FROM clientes);

INSERT INTO clientes (nome, cidade)
SELECT 'Lucas', 'Guarabira'
WHERE (SELECT COUNT(*) FROM clientes) = 1;

INSERT INTO clientes (nome, cidade)
SELECT 'Bruna', 'Campina Grande'
WHERE (SELECT COUNT(*) FROM clientes) = 2;


INSERT INTO produtos (nome, preco, estoque)
SELECT 'Notebook', 3000.00, 10
WHERE NOT EXISTS (SELECT 1 FROM produtos);

INSERT INTO produtos (nome, preco, estoque)
SELECT 'Mouse', 100.00, 20
WHERE (SELECT COUNT(*) FROM produtos) = 1;

INSERT INTO produtos (nome, preco, estoque)
SELECT 'Teclado', 200.00, 15
WHERE (SELECT COUNT(*) FROM produtos) = 2;


-- Conferir o banco
SELECT * FROM clientes;
SELECT * FROM produtos;
SELECT * FROM pedidos;
