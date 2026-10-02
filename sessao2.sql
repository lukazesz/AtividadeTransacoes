-- SESSÃO 2 - PASSO 1
BEGIN;

-- SESSÃO 2 - PASSO 2
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- SESSÃO 2 - PASSO 3
-- Altera o preço do Notebook
UPDATE produtos
SET preco = 3500
WHERE id = 1;

-- SESSÃO 2 - PASSO 4
-- Confirma a alteração
COMMIT;

-- agr vamo voltar pra sessão1

-- EXERCÍCIO 7 - REPEATABLE READ
-- SESSÃO 2 - PASSO v

-- SESSÃO 2 - PASSO 1
BEGIN;

-- SESSÃO 2 - PASSO 2
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- SESSÃO 2 - PASSO 3
UPDATE produtos
SET preco = 3500
WHERE id = 1;

-- SESSÃO 2 - PASSO 4
COMMIT;

-- agr voltamos pra sessão1

-- EXERCÍCIO 8A - PHANTOM READ
-- PARTE A - READ COMMITTED

-- SESSÃO 2 - PASSO 1
BEGIN;

-- SESSÃO 2 - PASSO 2
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- SESSÃO 2 - PASSO 3
-- preco >= 200.
INSERT INTO produtos (nome, preco, estoque)
VALUES ('Monitor', 800, 10);

-- SESSÃO 2 - PASSO 4
COMMIT;

-- volta pra sessão1

-- EXERCÍCIO 8B - EVITANDO PHANTOM READ
-- REPEATABLE READ

-- SESSÃO 2 - PASSO 1
BEGIN;

-- SESSÃO 2 - PASSO 2
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- SESSÃO 2 - PASSO 3
INSERT INTO produtos (nome, preco, estoque)
VALUES ('Monitor 2', 900, 10);

-- SESSÃO 2 - PASSO 4
COMMIT;

-- voltar pra sessão1.

-- EXERCÍCIO 9A - UPDATE CONCORRENTE
-- READ COMMITTED

-- SESSÃO 2 - PASSO 1
BEGIN;

-- SESSÃO 2 - PASSO 2
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- SESSÃO 2 - PASSO 3
-- Tente alterar o MESMO registro.
-- A sessão poderá ficar aguardando.
UPDATE produtos
SET preco = 3500
WHERE id = 1;

-- voltando pra sessão1

-- SESSÃO 2 - PASSO 4
-- Depois que a Sessão 1 liberar o registro,
-- a Sessão vai 2 poder continuar.

COMMIT;

-- EXERCÍCIO 9B - UPDATE CONCORRENTE
-- SERIALIZABLE

-- SESSÃO 2 - PASSO 1
BEGIN;

-- SESSÃO 2 - PASSO 2
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- SESSÃO 2 - PASSO 3
-- Tenta alterar o mesmo registro.
-- Pode ficar aguardando.
UPDATE produtos
SET preco = 3500
WHERE id = 1;

-- voltando pra s1

-- SESSÃO 2 - PASSO 4
/* Dependendo do conflito, o PostgreSQL poderá apresentar um erro semelhante a:
ERROR: could not serialize access due to concurrent update. Isso é esperado no teste de SERIALIZABLE.
Se a transação estiver abortada:
*/
ROLLBACK;

-- EXERCÍCIO 9C - UPDATE CONCORRENTE 
-- SERIALIZABLE + ROLLBACK

-- SESSÃO 2 - PASSO 1
BEGIN;

-- SESSÃO 2 - PASSO 2
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- SESSÃO 2 - PASSO 3
UPDATE produtos
SET preco = 3500
WHERE id = 1;

-- voltando pra s1

-- SESSÃO 2 - PASSO 4
-- Depois que a Sessão 1 liberar o registro,
-- a Sessão 2 poderá continuar.

-- Se necessário, execute novamente o UPDATE:
UPDATE produtos
SET preco = 3500
WHERE id = 1;

-- SESSÃO 2 - PASSO 5
COMMIT;

SELECT *
FROM produtos
WHERE id = 1;







