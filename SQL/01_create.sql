DROP TABLE IF EXISTS dbo.change_log
DROP TABLE IF EXISTS dbo.factura_contribuinte
DROP TABLE IF EXISTS dbo.contribuinte
DROP TABLE IF EXISTS dbo.devolucao
DROP TABLE IF EXISTS dbo.nota_credito
DROP TABLE IF EXISTS dbo.item
DROP TABLE IF EXISTS dbo.produto
DROP TABLE IF EXISTS dbo.factura

DROP FUNCTION IF EXISTS dbo.con_subconjunto_items_vazio
DROP FUNCTION IF EXISTS dbo.con_devolucao_subconjunto_vazio
DROP FUNCTION IF EXISTS dbo.con_factura_nao_emitida
DROP FUNCTION IF EXISTS dbo.con_devolucao_quantidade_excedida
DROP FUNCTION IF EXISTS dbo.get_ip
DROP FUNCTION IF EXISTS dbo.get_user
GO

/*##############################################################################################
Integrity check functions creation*/

CREATE FUNCTION dbo.con_subconjunto_items_vazio(@factura_codigo VARCHAR(12))
RETURNS BIT AS BEGIN
	IF (EXISTS (SELECT factura_codigo FROM dbo.item WHERE factura_codigo = @factura_codigo)) BEGIN
		RETURN 0
	END
	RETURN 1
END
GO

CREATE FUNCTION dbo.con_devolucao_subconjunto_vazio(@nota_credito_codigo VARCHAR(12))
RETURNS BIT AS BEGIN
	IF (EXISTS (SELECT nota_credito_codigo FROM devolucao WHERE nota_credito_codigo = @nota_credito_codigo)) BEGIN
		RETURN 0
	END
	RETURN 1
END
GO

CREATE FUNCTION dbo.con_factura_nao_emitida(@factura_codigo VARCHAR(12))
RETURNS BIT AS BEGIN
	IF (EXISTS (SELECT codigo FROM dbo.factura WHERE codigo = @factura_codigo AND estado = 2)) BEGIN
		RETURN 0
	END
	RETURN 1
END
GO

CREATE FUNCTION dbo.con_devolucao_quantidade_excedida(@factura_codigo VARCHAR(12), @item_numero NUMERIC(3))
RETURNS BIT AS BEGIN
	DECLARE @maximo NUMERIC(10)
	SELECT @maximo = quantidade FROM dbo.item WHERE factura_codigo = @factura_codigo AND numero = @item_numero
	
	DECLARE @total NUMERIC(10)
	SELECT @total = SUM(quantidade) FROM dbo.devolucao WHERE factura_codigo = @factura_codigo AND item_numero = @item_numero
	
	IF(@total > @maximo) BEGIN
		RETURN 1
	END
	
	RETURN 0
END
GO

CREATE FUNCTION dbo.get_ip()
RETURNS VARCHAR(48) AS BEGIN
	DECLARE @ret VARCHAR(48)
	SELECT @ret = client_net_address FROM sys.dm_exec_connections WHERE Session_id = @@SPID;
	RETURN @ret
END
GO
CREATE FUNCTION dbo.get_user()
RETURNS NCHAR(128) AS BEGIN
	DECLARE @ret NCHAR(128)
	SELECT @ret = loginame FROM sys.sysprocesses WHERE spid = @@SPID
	RETURN @ret
END
GO

/*##############################################################################################
Table creation*/

/*
STATE:
0 UPDATING
1 PROFORMA
2 EMITTED
3 CANCELED
*/
CREATE TABLE dbo.factura(
	codigo			VARCHAR(12) PRIMARY KEY,
	estado			NUMERIC(1) DEFAULT(0) NOT NULL,
	data_criacao	DATETIME NOT NULL DEFAULT GETDATE(),
	data_complecao	DATETIME DEFAULT NULL,
	preco			DECIMAL(7,2),
	iva				DECIMAL(7,2),
	
	CONSTRAINT factura_subconjunto_items_vazio CHECK(estado != 2 OR (dbo.con_subconjunto_items_vazio(codigo) = 0)),
	CONSTRAINT factura_data_criacao_invalida CHECK(data_criacao <= GETDATE()),
	CONSTRAINT factura_estado_invalido CHECK(estado BETWEEN 0 AND 3),
	CONSTRAINT factura_data_complecao_invalida CHECK(((estado < 2 AND data_complecao IS NULL) OR (estado > 1 AND data_complecao IS NOT NULL AND data_complecao > data_criacao AND data_complecao <= GETDATE()))),
	CONSTRAINT factura_precoiva_nao_positivo CHECK(preco >= 0 AND iva >= 0)
)

CREATE TABLE dbo.contribuinte(
	id				NUMERIC(9) PRIMARY KEY,
	nome			VARCHAR(20),
	morada			VARCHAR(256),
	
	CONSTRAINT contribuinte_id_invalido CHECK(id > 0)
)

CREATE TABLE dbo.factura_contribuinte(
	factura_codigo	VARCHAR(12) REFERENCES factura(codigo),
	contribuinte_id	NUMERIC(9) REFERENCES contribuinte(id),
	
	PRIMARY KEY(factura_codigo)
)

CREATE TABLE dbo.produto(
	sku				INT IDENTITY(1,1) PRIMARY KEY,
	preco			DECIMAL(7,2) NOT NULL,
	iva				DECIMAL(6,5) NOT NULL,
	descricao		VARCHAR(256),
	
	CONSTRAINT produto_preco_nao_positivo CHECK(preco > 0),
	CONSTRAINT produto_iva_nao_positivo CHECK(iva > 0)
)

CREATE TABLE dbo.item(
	numero			NUMERIC(3) NOT NULL,
	quantidade		NUMERIC(10) NOT NULL,
	desconto		DECIMAL(6,5) NOT NULL,
	descricao		VARCHAR(255),
	produto_sku		INT REFERENCES produto(sku),
	factura_codigo	VARCHAR(12) REFERENCES factura(codigo),
	
	PRIMARY KEY(numero,factura_codigo),
	CONSTRAINT item_quantidade_nao_positiva CHECK(quantidade > 0)
)

/*
estado:
0 UPDATING
1 EMITTED
*/
CREATE TABLE dbo.nota_credito(
	codigo			VARCHAR(12) UNIQUE,
	estado			NUMERIC(1) DEFAULT(0) NOT NULL,
	data_criacao	DATETIME NOT NULL DEFAULT GETDATE(),
	data_complecao	DATETIME DEFAULT NULL,
	factura_codigo	VARCHAR(12) REFERENCES factura(codigo),
	preco			DECIMAL(7,2),
	iva				DECIMAL(7,2),
	
	PRIMARY KEY(codigo, factura_codigo),
	CONSTRAINT nota_credito_devolucao_subconjunto_vazio CHECK(estado = 0 OR (dbo.con_devolucao_subconjunto_vazio(codigo) = 0)),
	CONSTRAINT nota_credito_data_criacao_invalida CHECK(data_criacao <= GETDATE()),
	CONSTRAINT nota_credito_estado_invalido CHECK(estado BETWEEN 0 AND 1),
	CONSTRAINT nota_credito_data_complecao_invalida CHECK(((estado = 0 AND data_complecao IS NULL) OR (estado = 1 AND data_complecao IS NOT NULL AND data_complecao > data_criacao AND data_complecao <= GETDATE()))),
	CONSTRAINT nota_credito_factura_nao_emitida CHECK(dbo.con_factura_nao_emitida(factura_codigo) = 0),
	CONSTRAINT nota_credito_precoiva_nao_positivo CHECK(preco >= 0 AND iva >= 0),
)

CREATE TABLE dbo.devolucao(
	quantidade			NUMERIC(10) NOT NULL,
	item_numero			NUMERIC(3) NOT NULL,
	factura_codigo		VARCHAR(12) NOT NULL,
	nota_credito_codigo	VARCHAR(12) NOT NULL,
	
	PRIMARY KEY(item_numero,nota_credito_codigo),
	FOREIGN KEY(item_numero, factura_codigo) REFERENCES item(numero, factura_codigo),
	FOREIGN KEY(nota_credito_codigo, factura_codigo) REFERENCES nota_credito(codigo,factura_codigo),
	CONSTRAINT devolucao_quantidade_nao_positiva CHECK(quantidade > 0),
	CONSTRAINT devolucao_quantidade_excedida CHECK (dbo.con_devolucao_quantidade_excedida(factura_codigo, item_numero) = 0)
)

CREATE TABLE dbo.change_log(
	id				INT IDENTITY(1,1) PRIMARY KEY,
	data_evento		DATETIME NOT NULL DEFAULT GETDATE(),
	evento			VARCHAR(256) NOT NULL,
	estado			NUMERIC(1) NOT NULL,
	ip				VARCHAR(48) NOT NULL DEFAULT dbo.get_ip(),
	utilizador		NCHAR(128) NOT NULL DEFAULT dbo.get_user(),
	factura_codigo	VARCHAR(12) REFERENCES factura(codigo)
)
GO

/*##############################################################################################
Trigger creation*/


/*#############*/
/*change_log insertions*/

/*Create an entry in change_log everytime an invoice is created or altered*/
CREATE TRIGGER dbo.trig_factura_alterada ON dbo.factura AFTER INSERT, UPDATE AS BEGIN
	
	DECLARE @evento VARCHAR(256)
	
	IF(EXISTS(SELECT * FROM deleted)) BEGIN
		SET @evento = 'FACTURA ACTUALIZADA'
	END
	ELSE BEGIN
		SET @evento = 'FACTURA CRIADA'
	END
	INSERT INTO dbo.change_log(evento,estado,factura_codigo) SELECT @evento, estado, codigo FROM inserted
END
GO

/*Create an entry in change_log everytime a taxpayer is added to a invoice*/
CREATE TRIGGER dbo.trig_contribuinte_adicionado ON dbo.factura_contribuinte AFTER INSERT AS BEGIN
	INSERT INTO dbo.change_log(evento,estado,factura_codigo) SELECT 'CONTRIBUINTE ADICIONADO A FACTURA', estado, codigo FROM dbo.factura WHERE codigo IN (SELECT factura_codigo FROM inserted)
END
GO
/*Create an entry in change_log everytime an item from the invoice is created or removed */
CREATE TRIGGER dbo.trig_item_alterado ON dbo.item AFTER INSERT, DELETE AS BEGIN
	INSERT INTO dbo.change_log(evento,estado,factura_codigo) SELECT 'ITEM REMOVIDO', estado, codigo FROM dbo.factura WHERE codigo IN (SELECT factura_codigo FROM deleted)
	INSERT INTO dbo.change_log(evento,estado,factura_codigo) SELECT 'ITEM ADICIONADO', estado, codigo FROM dbo.factura WHERE codigo IN (SELECT factura_codigo FROM inserted)
END
GO
/*Create an entry in change_log everytime a credit note is created or altered*/
CREATE TRIGGER dbo.trig_nota_credito_alterada ON dbo.nota_credito AFTER INSERT, UPDATE AS BEGIN
	
	DECLARE @evento VARCHAR(256)
	
	IF(EXISTS(SELECT * FROM deleted)) BEGIN
		SET @evento = 'NOTA DE CREDITO ACTUALIZADA'
	END
	ELSE BEGIN
		SET @evento = 'NOTA DE CREDITO CRIADA'
	END
	INSERT INTO dbo.change_log(evento,estado,factura_codigo) SELECT @evento, estado, codigo FROM dbo.factura WHERE codigo IN (SELECT factura_codigo from inserted)
END
GO

/*Create an entry in change_log everytime an item from the devolution list is created or removed*/
CREATE TRIGGER dbo.trig_devolucao_alterada ON dbo.devolucao AFTER INSERT, DELETE AS BEGIN
	INSERT INTO dbo.change_log(evento,estado,factura_codigo) SELECT 'ITEM A DEVOLVER REMOVIDO', estado, codigo FROM dbo.factura WHERE codigo IN (SELECT factura_codigo FROM deleted)
	INSERT INTO dbo.change_log(evento,estado,factura_codigo) SELECT 'ITEM A DEVOLVER ADICIONADO', estado, codigo FROM dbo.factura WHERE codigo IN (SELECT factura_codigo FROM inserted)
END
GO
/*#############*/
/*updates of price and iva values in nota_credito/factura*/

/*Update values of total and IVA from invoice when it enters state 1*/
CREATE TRIGGER dbo.trig_factura_valor_atualizado ON dbo.factura AFTER UPDATE AS BEGIN


	DECLARE cur CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR SELECT codigo, estado FROM inserted		
	OPEN cur
	
	DECLARE @codigo VARCHAR(12)
	DECLARE @estado NUMERIC(1)
	DECLARE @evento VARCHAR(256)
	
	FETCH NEXT FROM cur INTO @codigo, @estado
	
	WHILE @@FETCH_STATUS = 0 BEGIN
		IF(@estado = 1)BEGIN
			DECLARE @preco DECIMAL(7,2)
			DECLARE @iva   DECIMAL(7,2) 
		
			SELECT @preco = SUM(preco*quantidade*(1-desconto)),@iva = SUM(preco*quantidade*(1-desconto)*iva) FROM (dbo.produto INNER JOIN dbo.item ON sku = produto_sku)  WHERE factura_codigo = @codigo
			UPDATE dbo.factura SET iva = @iva, preco = @preco WHERE codigo = @codigo

			SET @evento = 'FACTURA VALOR ACTUALIZADO'
			INSERT INTO dbo.change_log(evento,estado,factura_codigo) VALUES (@evento,@estado,@codigo)
		END
		
		FETCH NEXT FROM cur INTO @codigo, @estado
	END
	CLOSE cur
	DEALLOCATE cur;
END
GO
/*Update values of total and IVA when a credit note enters state 1*/

CREATE TRIGGER dbo.trig_nota_credito_valor_atualizado ON dbo.nota_credito AFTER UPDATE AS BEGIN

	DECLARE cur CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR SELECT factura_codigo, estado, codigo FROM inserted	
	OPEN cur

	DECLARE @factura_codigo VARCHAR(12)
	DECLARE @nota_credito_codigo VARCHAR(12)
	DECLARE @estado NUMERIC(1)

	FETCH NEXT FROM cur INTO @factura_codigo, @estado, @nota_credito_codigo

	WHILE @@FETCH_STATUS = 0 BEGIN
		IF(@estado = 1) BEGIN
	
			DECLARE @preco DECIMAL(7,2)
			DECLARE @iva   DECIMAL(7,2)	

			SELECT @preco = sum(preco*devolucao.quantidade*(1-desconto)),@iva = sum(preco*devolucao.quantidade*(1-desconto)*iva) 
			FROM (dbo.devolucao INNER JOIN (
				dbo.item INNER JOIN dbo.produto ON sku = produto_sku
			) ON (devolucao.factura_codigo = item.factura_codigo AND devolucao.item_numero = item.numero)) WHERE devolucao.factura_codigo = @factura_codigo

			UPDATE dbo.nota_credito SET iva = @iva, preco = @preco WHERE codigo = @nota_credito_codigo
		
			SELECT @estado = estado FROM dbo.factura WHERE codigo = @factura_codigo
			DECLARE @evento VARCHAR(256)
			SET @evento = 'NOTA CREDITO VALOR ATUALIZADO'
			INSERT INTO dbo.change_log(evento,estado,factura_codigo) VALUES (@evento,@estado,@factura_codigo)
		END
		FETCH NEXT FROM cur INTO @factura_codigo, @estado, @nota_credito_codigo
	END
	CLOSE cur
	DEALLOCATE cur;
END
GO

