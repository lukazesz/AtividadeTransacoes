# Atividade Transações

## 1. O que é uma transação?

Uma transação é um conjunto de operações realizadas no banco de dados que é tratado como uma única unidade de trabalho. Ela pode ser confirmada com `COMMIT` ou desfeita com `ROLLBACK`.

---

## 2. Qual é o significado da sigla ACID?

ACID representa quatro propriedades das transações:

* **A — Atomicidade:** todas as operações da transação são realizadas ou nenhuma é realizada.
* **C — Consistência:** a transação deve manter o banco de dados em um estado válido.
* **I — Isolamento:** uma transação não deve interferir de forma inadequada em outra transação concorrente.
* **D — Durabilidade:** depois de um `COMMIT`, as alterações permanecem armazenadas no banco de dados.

---

## 3. Explique o funcionamento dos comandos BEGIN, SAVEPOINT, COMMIT e ROLLBACK.

* **BEGIN:** inicia uma transação.

```sql
BEGIN;
```

* **SAVEPOINT:** cria um ponto dentro da transação para o qual podemos retornar posteriormente.

```sql
SAVEPOINT ponto1;
```

* **COMMIT:** confirma definitivamente as alterações realizadas pela transação.

```sql
COMMIT;
```

* **ROLLBACK:** desfaz as alterações realizadas pela transação.

```sql
ROLLBACK;
```

Também é possível voltar somente até um `SAVEPOINT`:

```sql
ROLLBACK TO ponto1;
```

---

## 4. Quais são os problemas de isolamento que podem acontecer quando existem transações concorrentes?

Os principais problemas são:

* **Dirty Read (leitura suja):** ocorre quando uma transação lê dados alterados por outra transação que ainda não realizou `COMMIT`.
* **Non-repeatable Read (leitura não repetível):** ocorre quando a mesma consulta retorna valores diferentes porque outra transação alterou e confirmou os dados entre as duas consultas.
* **Phantom Read (leitura fantasma):** ocorre quando a mesma consulta retorna uma quantidade ou conjunto diferente de linhas porque outra transação inseriu, removeu ou alterou registros que atendem à condição da consulta.

---

## 5. Quais são os níveis de isolamento que podem ser utilizados em uma transação? Explique cada um deles.

### READ UNCOMMITTED

É o nível mais permissivo. No padrão SQL, permite que uma transação leia alterações ainda não confirmadas por outra. No PostgreSQL, entretanto, ele se comporta como `READ COMMITTED`.

### READ COMMITTED

Uma transação só enxerga dados confirmados. Porém, duas consultas realizadas dentro da mesma transação podem apresentar resultados diferentes caso outra transação altere e confirme os dados entre elas.

É o nível padrão do PostgreSQL.

### REPEATABLE READ

A transação mantém um mesmo snapshot dos dados durante sua execução. Dessa forma, novas consultas realizadas na mesma transação continuam enxergando o mesmo estado dos dados.

### SERIALIZABLE

É o nível mais rigoroso de isolamento. Procura garantir que as transações concorrentes tenham um resultado equivalente ao de uma execução sequencial. Em caso de conflito, uma transação pode ser abortada com erro de serialização e precisar ser executada novamente.

---

## 6. Como configurar o nível de isolamento de uma transação? Dê exemplo.

O nível pode ser configurado usando `SET TRANSACTION ISOLATION LEVEL` após iniciar a transação.

Exemplo:

```sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

Outro exemplo:

```sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
```

Ou:

```sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

---

# 7. Experimento com duas sessões

Para os exemplos, foi utilizado um modelo de banco de dados de uma loja, contendo as tabelas `clientes`, `produtos` e `pedidos`.

Exemplo de tabela utilizada nos testes:

```sql
CREATE TABLE produtos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100),
    preco NUMERIC(10,2),
    estoque INT
);
```

Registros utilizados:

```sql
INSERT INTO produtos (nome, preco, estoque) VALUES
('Notebook', 3000.00, 10),
('Mouse', 100.00, 20),
('Teclado', 200.00, 15);
```

---

# 7 — READ COMMITTED

### SESSÃO 1 — item iii

```sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

### SESSÃO 1 — item iv

```sql
SELECT * FROM produtos;
```

O produto Notebook possui inicialmente o preço de `3000`.

### SESSÃO 2 — item v

```sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

UPDATE produtos
SET preco = 3500
WHERE id = 1;
```

Nesse momento, a SESSÃO 2 ainda não realizou `COMMIT`.

### vi. Repita o passo iv. O que aconteceu e por quê?

```sql
SELECT * FROM produtos;
```

A SESSÃO 1 continua vendo o preço de `3000`.

Isso acontece porque a alteração realizada pela SESSÃO 2 ainda não foi confirmada. Portanto, a SESSÃO 1 não consegue visualizar essa alteração.

### vii. Na SESSÃO 2, execute COMMIT.

```sql
COMMIT;
```

### viii. Repita o passo iv. O que aconteceu e por quê?

```sql
SELECT * FROM produtos;
```

Agora a SESSÃO 1 passa a visualizar o preço de `3500`.

Isso acontece porque a SESSÃO 2 realizou `COMMIT`. Como o nível utilizado é `READ COMMITTED`, cada nova consulta pode enxergar as alterações que já foram confirmadas por outras transações.

Esse comportamento demonstra uma **non-repeatable read**, pois a mesma consulta apresentou valores diferentes dentro da transação.

### ix. Na SESSÃO 1, execute COMMIT.

```sql
COMMIT;
```

### x. Repita o passo iv. O que aconteceu e por quê?

```sql
SELECT * FROM produtos;
```

O preço continua sendo `3500`, pois a alteração já foi confirmada pela SESSÃO 2 e a transação da SESSÃO 1 também foi finalizada.

---

# 7 — REPEATABLE READ

O experimento deve ser repetido utilizando:

```sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
```

Inicialmente, o Notebook possui preço `3000`.

Na SESSÃO 2:

```sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

UPDATE produtos
SET preco = 3500
WHERE id = 1;
```

### vi. Repita o passo iv. O que aconteceu e por quê?

A SESSÃO 1 continua vendo o preço `3000`, porque a alteração da SESSÃO 2 ainda não foi confirmada.

### vii. SESSÃO 2:

```sql
COMMIT;
```

### viii. Repita o passo iv. O que aconteceu e por quê?

```sql
SELECT * FROM produtos;
```

A SESSÃO 1 continua vendo `3000`, mesmo depois do `COMMIT` da SESSÃO 2.

Isso acontece porque, no `REPEATABLE READ` do PostgreSQL, a transação utiliza um mesmo snapshot durante sua execução. Portanto, as consultas realizadas dentro da transação continuam enxergando o estado anterior.

### ix. SESSÃO 1:

```sql
COMMIT;
```

### x. Repita o passo iv. O que aconteceu e por quê?

Após finalizar a transação e realizar uma nova consulta, o valor atualizado de `3500` será visualizado, pois a nova consulta não está mais limitada ao snapshot da transação anterior.

---

# 8. Phantom Read

## 8a. Usando READ COMMITTED

### SESSÃO 1

```sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT *
FROM produtos
WHERE preco >= 200;
```

Inicialmente, podem aparecer:

```text
Notebook
Teclado
```

### SESSÃO 2

```sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

INSERT INTO produtos (nome, preco, estoque)
VALUES ('Monitor', 800, 10);

COMMIT;
```

### SESSÃO 1

Repita a consulta:

```sql
SELECT *
FROM produtos
WHERE preco >= 200;
```

Agora o `Monitor` também aparece.

### Resposta

Ocorreu um **Phantom Read**, porque a segunda execução da mesma consulta encontrou uma nova linha que não estava presente na primeira consulta. Isso ocorreu porque a SESSÃO 2 inseriu e confirmou um novo registro entre as duas consultas.

---

## 8b. Usando REPEATABLE READ

### SESSÃO 1

```sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT *
FROM produtos
WHERE preco >= 200;
```

### SESSÃO 2

```sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

INSERT INTO produtos (nome, preco, estoque)
VALUES ('Celular', 1500, 10);

COMMIT;
```

### SESSÃO 1

```sql
SELECT *
FROM produtos
WHERE preco >= 200;
```

O novo `Celular` não aparece na consulta da SESSÃO 1.

### Resposta

No PostgreSQL, o `REPEATABLE READ` utiliza o mesmo snapshot durante a transação. Por isso, o novo registro confirmado pela SESSÃO 2 não aparece para a SESSÃO 1 enquanto ela permanecer na mesma transação.

---

# 9. Concorrência entre duas transações

## 9a. Usando READ COMMITTED

### i. Iniciar as duas transações

### SESSÃO 1

```sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

### SESSÃO 2

```sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

### ii. Atualizar a mesma tupla

### SESSÃO 1

```sql
UPDATE produtos
SET preco = 150
WHERE id = 2;
```

### SESSÃO 2

```sql
UPDATE produtos
SET preco = 180
WHERE id = 2;
```

### iii. O que acontece na transação 2? Por quê?

A SESSÃO 2 fica aguardando a liberação do bloqueio da linha pela SESSÃO 1.

Isso acontece porque as duas transações estão tentando atualizar a mesma tupla simultaneamente.

### iv. Faça COMMIT na transação 1. Agora o que aconteceu na transação 2?

Na SESSÃO 1:

```sql
COMMIT;
```

Após o `COMMIT`, o bloqueio é liberado e a SESSÃO 2 pode continuar sua operação.

---

# 9b. Usando SERIALIZABLE

### i. Inicie as duas transações

### SESSÃO 1

```sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

### SESSÃO 2

```sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

### ii. Atualize a mesma tupla

### SESSÃO 1

```sql
UPDATE produtos
SET preco = 150
WHERE id = 2;
```

### SESSÃO 2

```sql
UPDATE produtos
SET preco = 180
WHERE id = 2;
```

### iii. O que acontece na transação 2?

A SESSÃO 2 fica aguardando porque a SESSÃO 1 está trabalhando sobre a mesma tupla.

### iv. Faça COMMIT na transação 1. Agora o que aconteceu na transação 2?

Na SESSÃO 1:

```sql
COMMIT;
```

A SESSÃO 2 pode receber um erro de serialização, pois o PostgreSQL detecta que as operações concorrentes não podem ser executadas de forma serializável.

Um erro possível é:

```text
ERROR: could not serialize access due to concurrent update
```

Nesse caso, a transação da SESSÃO 2 deve ser reiniciada.

---

# 9c. SERIALIZABLE usando ROLLBACK

### i. Inicie as duas transações

### SESSÃO 1

```sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

### SESSÃO 2

```sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

### ii. Atualize a mesma tupla

### SESSÃO 1

```sql
UPDATE produtos
SET preco = 150
WHERE id = 2;
```

### SESSÃO 2

```sql
UPDATE produtos
SET preco = 180
WHERE id = 2;
```

### iii. O que acontece na transação 2?

A SESSÃO 2 fica aguardando a liberação do bloqueio da SESSÃO 1.

### iv. Faça ROLLBACK na transação 1. Agora o que aconteceu na transação 2?

Na SESSÃO 1:

```sql
ROLLBACK;
```

O `ROLLBACK` desfaz a alteração feita pela SESSÃO 1 e libera o bloqueio da linha.

Com isso, a SESSÃO 2 pode continuar o seu `UPDATE`.

Depois, a SESSÃO 2 pode confirmar a alteração:

```sql
COMMIT;
```

Nesse caso, o valor final do produto será `180`.

---

# Resumo dos principais comandos

```sql
BEGIN;
```

Inicia uma transação.

```sql
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

Define o nível de isolamento.

```sql
SAVEPOINT ponto1;
```

Cria um ponto de salvamento.

```sql
COMMIT;
```

Confirma as alterações.

```sql
ROLLBACK;
```

Desfaz as alterações.

```sql
ROLLBACK TO ponto1;
```

Volta para um `SAVEPOINT`.

# Resumo dos níveis

| Nível            | Característica                                                        |
| ---------------- | --------------------------------------------------------------------- |
| READ UNCOMMITTED | Mais permissivo; no PostgreSQL funciona como READ COMMITTED           |
| READ COMMITTED   | Enxerga dados confirmados a cada comando                              |
| REPEATABLE READ  | Mantém o mesmo snapshot durante a transação                           |
| SERIALIZABLE     | Maior nível de isolamento; conflitos podem gerar erro de serialização |


