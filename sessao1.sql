-- EXERCÍCIO 7 - READ COMMITTED

-- SESSÃO 1 - PASSO 1
BEGIN;

-- SESSÃO 1 - PASSO 2
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- SESSÃO 1 - PASSO 3
-- Primeira leitura: deve mostrar 3000
SELECT *
FROM produtos
WHERE id = 1;

-- vamo pra sessão2

-- SESSÃO 1 - PASSO 4

SELECT *
FROM produtos
WHERE id = 1;

-- SESSÃO 1 - PASSO 5
COMMIT;

-- fim

-- EXERCÍCIO 7 - REPEATABLE READ

-- Antes de começar, voltando o Notebook para 3000.
-- Execute fora de uma transação.


UPDATE produtos
SET preco = 3000
WHERE id = 1;

-- SESSÃO 1 - PASSO 1
BEGIN;

-- SESSÃO 1 - PASSO 2
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- SESSÃO 1 - PASSO 3
-- Primeira leitura: deve mostrar 3000.
SELECT *
FROM produtos
WHERE id = 1;

-- bora pra sessão2

-- SESSÃO 1 - PASSO 4
-- Mesmo depois do COMMIT da Sessão 2, vai continuar mostrando 3000.
SELECT *
FROM produtos
WHERE id = 1;

-- SESSÃO 1 - PASSO 5
COMMIT;

-- fim

-- EXERCÍCIO 8 - PHANTOM READ
-- READ COMMITTED

-- SESSÃO 1 - PASSO 1
BEGIN;

-- SESSÃO 1 - PASSO 2
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- SESSÃO 1 - PASSO 3
SELECT *
FROM produtos
WHERE preco >= 200;

-- vamo pra sessão2

-- SESSÃO 1 - PASSO 4
-- Executando novamente a mesma consulta.
-- O Monitor finalmente aparece
SELECT *
FROM produtos
WHERE preco >= 200;

-- SESSÃO 1 - PASSO 5
COMMIT;

-- PARTE B - REPEATABLE READ
-- EVITANDO PHANTOM READ

-- SESSÃO 1 - PASSO 1
BEGIN;

-- SESSÃO 1 - PASSO 2
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- SESSÃO 1 - PASSO 3
SELECT *
FROM produtos
WHERE preco >= 200;

-- partiu sessão2

-- SESSÃO 1 - PASSO 4
-- O Monitor 2 NÃO deverá aparecer nesta transação.
SELECT *
FROM produtos
WHERE preco >= 200;

-- SESSÃO 1 - PASSO 5
COMMIT;

-- EXERCÍCIO 9A - UPDATE CONCORRENTE 
-- READ COMMITTED

-- Antes do teste, voltando o Notebook para 3000:

UPDATE produtos
SET preco = 3000
WHERE id = 1;

-- SESSÃO 1 - PASSO 1
BEGIN;

-- SESSÃO 1 - PASSO 2
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- SESSÃO 1 - PASSO 3
UPDATE produtos
SET preco = 3200
WHERE id = 1;

-- bora pra sessão2

-- SESSÃO 1 - PASSO 4
COMMIT;

-- voltando pra s2

-- EXERCÍCIO 9B - UPDATE CONCORRENTE 
-- SERIALIZABLE + COMMIT

UPDATE produtos
SET preco = 3000
WHERE id = 1;

-- SESSÃO 1 - PASSO 1
BEGIN;

-- SESSÃO 1 - PASSO 2
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- SESSÃO 1 - PASSO 3
UPDATE produtos
SET preco = 3200
WHERE id = 1;

-- continua na s2

-- SESSÃO 1 - PASSO 4
-- Confirma sua alteração.
COMMIT;

-- voltando pra s2

-- EXERCÍCIO 9C - UPDATE CONCORRENTE 
-- SERIALIZABLE + ROLLBACK

UPDATE produtos
SET preco = 3000
WHERE id = 1;

-- SESSÃO 1 - PASSO 1
BEGIN;

-- SESSÃO 1 - PASSO 2
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- SESSÃO 1 - PASSO 3
UPDATE produtos
SET preco = 3200
WHERE id = 1;

-- bora pra s2

-- SESSÃO 1 - PASSO 4
-- Em vez de COMMIT, vamos desfazer a alteração.
ROLLBACK;

-- voltando pra s2













