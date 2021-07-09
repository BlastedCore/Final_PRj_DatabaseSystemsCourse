DROP FUNCTION IF EXISTS cliente.f_listarNotasCredito
DROP PROC IF EXISTS cliente.p_notaCreditoEmitir
DROP PROC IF EXISTS cliente.p_facturaAnular
DROP PROC IF EXISTS cliente.p_facturaEmitir
DROP PROC IF EXISTS cliente.p_facturaProforma
DROP PROC IF EXISTS cliente.p_criaNotaCredito
DROP PROC IF EXISTS cliente.p_criaFactura
DROP PROC IF EXISTS cliente.p_proxNotaCredito
DROP PROC IF EXISTS cliente.p_proxFactura
DROP PROC IF EXISTS cliente.p_prox
DROP VIEW IF EXISTS cliente.factura
DROP VIEW IF EXISTS cliente.devolucao
DROP VIEW IF EXISTS cliente.item
DROP VIEW IF EXISTS cliente.produto
DROP SCHEMA IF EXISTS cliente
GO

CREATE SCHEMA cliente 
GO


/*
Part of the integrity restrictions are guaranteed through these functions/view/proc,
for example maaking impossible removing Items from an Invoice after its already been emitted
*/

/*
Insert, remove and update info from a product (only description as the other values cannot be altered)
*/
	/*
	inserts are allowed and deletes are also allowed(only if the product hasnt been sold yet, otherwise the foreign key constraint check will trigger)
	but updates aren't allowed (if a product has been sold already)
	*/
CREATE VIEW cliente.produto AS
	SELECT sku AS SKU, preco AS Preco, iva AS IVA, descricao AS Descricao FROM dbo.produto
GO
	/*overwrite of updata so that you can only update the description, or a produt that hasnt been sold yet*/
CREATE TRIGGER cliente.trig_produto_restricao ON cliente.produto INSTEAD OF UPDATE AS BEGIN
	/*check if something other than the description was changed*/
	IF(EXISTS(SELECT * FROM inserted INNER JOIN deleted ON inserted.SKU = deleted.SKU WHERE inserted.Preco != deleted.Preco OR inserted.IVA != deleted.IVA)) BEGIN
		/*check if the product was sold*/
		IF(EXISTS(SELECT * FROM dbo.Item WHERE produto_sku IN (SELECT SKU FROM inserted))) BEGIN
			RAISERROR('Produto ja vendido, impossivel alterar',15,1)
			ROLLBACK TRANSACTION
			RETURN  
		END
	END
	UPDATE dbo.produto SET dbo.produto.preco = inserted.Preco, dbo.produto.iva = inserted.IVA, dbo.produto.descricao = inserted.Descricao FROM inserted WHERE dbo.produto.sku = inserted.SKU
	RETURN
END
GO

/*
Add an Item to an Invoice
Remove an Item from an Invoice
*/
CREATE VIEW cliente.item AS
	SELECT factura_codigo AS Factura, produto_sku AS Produto, numero AS Numero, quantidade AS Quantidade, desconto AS Desconto, descricao AS Descricao FROM dbo.Item
GO

CREATE TRIGGER cliente.trig_item_insertUpdate ON cliente.item INSTEAD OF INSERT, UPDATE AS BEGIN
	IF(EXISTS(SELECT * FROM dbo.factura WHERE ((codigo IN (SELECT Factura FROM inserted)) AND (estado BETWEEN 1 AND 3)))) BEGIN
		RAISERROR('Factura nao em actualizacao.', 15,1)
		ROLLBACK TRANSACTION
		RETURN
	END
	IF(EXISTS(SELECT * FROM deleted)) BEGIN
		UPDATE dbo.item SET dbo.item.quantidade = inserted.Quantidade, dbo.item.desconto = inserted.Desconto, dbo.item.descricao = inserted.Descricao FROM inserted WHERE dbo.item.numero = inserted.Numero AND dbo.item.factura_codigo = inserted.Factura
	END
	ELSE BEGIN
		INSERT INTO dbo.item(numero,quantidade,desconto,descricao,produto_sku,factura_codigo) SELECT Numero, Quantidade, Desconto, Descricao, Produto, Factura FROM inserted
	END
	RETURN
END
GO

CREATE TRIGGER cliente.trig_item_delete ON cliente.item INSTEAD OF DELETE AS BEGIN
	IF(EXISTS(SELECT * FROM dbo.factura WHERE ((codigo IN (SELECT Factura FROM deleted)) AND (estado BETWEEN 1 AND 3)))) BEGIN
		RAISERROR('Factura nao em actualizacao.', 15,1)
		ROLLBACK TRANSACTION;  
		RETURN  
	END
	DELETE FROM dbo.item FROM deleted WHERE dbo.item.factura_codigo = deleted.Factura AND dbo.item.numero = deleted.Numero
	RETURN
END
GO

/*
Add an Item to a Credit Note
Remove an Item from a Credit Note
*/
CREATE VIEW cliente.devolucao AS
	SELECT factura_codigo AS Factura, nota_credito_codigo AS NotaCredito, Item_numero AS Numero, quantidade AS Quantidade FROM dbo.devolucao
GO

CREATE TRIGGER cliente.trig_devolucao_insertUpdate ON cliente.devolucao INSTEAD OF INSERT, UPDATE AS BEGIN
	IF(EXISTS(SELECT * FROM dbo.nota_credito WHERE (codigo IN (SELECT NotaCredito FROM inserted) AND estado = 1))) BEGIN
		RAISERROR('Nota de Credito ja terminada.', 15,1)
		ROLLBACK TRANSACTION;  
		RETURN  
	END
	IF(EXISTS(SELECT * FROM deleted)) BEGIN
		UPDATE dbo.devolucao SET dbo.devolucao.quantidade = inserted.Quantidade FROM inserted
	END
	ELSE BEGIN
		INSERT INTO dbo.devolucao(quantidade, item_numero, factura_codigo, nota_credito_codigo) SELECT Quantidade, Numero, Factura, NotaCredito FROM inserted
	END
	RETURN
END
GO

CREATE TRIGGER cliente.trig_devolucao_delete ON cliente.devolucao INSTEAD OF DELETE AS BEGIN
	IF(EXISTS(SELECT * FROM dbo.nota_credito WHERE ((codigo IN (SELECT NotaCredito FROM deleted)) AND estado = 1))) BEGIN
		RAISERROR('Nota de Credito ja terminada.', 15,1)
		ROLLBACK TRANSACTION;  
		RETURN  
	END
	DELETE FROM dbo.devolucao FROM deleted WHERE dbo.devolucao.factura_codigo = deleted.Factura AND dbo.devolucao.item_numero = deleted.Numero AND dbo.devolucao.nota_credito_codigo = deleted.NotaCredito
	RETURN
END
GO

/*
View that shows an Invoice summary of atributes and info from Taxpayer, and allows changing the state of an Invoice
*/
CREATE VIEW cliente.factura AS
    SELECT 
        codigo AS Factura,
        estado AS Estado,
        data_criacao AS DataCriacao,
        data_complecao AS DataComplecao,
        preco AS Preco,
        iva AS IVA,
        id AS ID,
        nome AS Nome,
        morada AS Morada
    FROM dbo.factura LEFT JOIN (dbo.factura_contribuinte INNER JOIN dbo.contribuinte ON contribuinte_id = id) ON codigo = factura_codigo
GO

CREATE TRIGGER cliente.trig_inserir_factura ON cliente.factura INSTEAD OF INSERT AS BEGIN
	DECLARE cur CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR SELECT ID, Nome, Morada FROM inserted
	OPEN cur
	
	DECLARE @ID NUMERIC(9)
	DECLARE @Nome VARCHAR(20)
	DECLARE @Morada VARCHAR(256)
	
	FETCH NEXT FROM cur INTO @ID, @Nome, @Morada
	
	WHILE @@FETCH_STATUS = 0 BEGIN
		EXEC cliente.p_criaFactura @ID, @Nome, @Morada
		FETCH NEXT FROM cur INTO @ID, @Nome, @Morada
	END
	CLOSE cur
	DEALLOCATE cur;
	RETURN
END
GO

CREATE TRIGGER cliente.trig_actualizar_factura ON cliente.factura INSTEAD OF UPDATE AS BEGIN
	/*Verify state of Invoice*/
	IF(EXISTS(SELECT * FROM inserted INNER JOIN deleted ON inserted.Factura = deleted.Factura WHERE (deleted.Estado = 0 AND (inserted.Estado NOT BETWEEN 0 AND 1)) OR (deleted.Estado = 1 AND (inserted.Estado NOT BETWEEN 1 AND 3)) OR deleted.Estado BETWEEN 2 AND 3)) BEGIN
		RAISERROR('Estado invalido', 15,1)
		ROLLBACK TRANSACTION;  
		RETURN  
	END
	
	/*create Taxpayer*/
	INSERT INTO dbo.contribuinte(id, nome, morada) SELECT ID, Nome, Morada FROM inserted WHERE ID NOT IN (SELECT id FROM dbo.contribuinte)
	--ligar contribuinte a factura
	INSERT INTO dbo.factura_contribuinte(factura_codigo, contribuinte_id) SELECT Factura, ID FROM inserted WHERE Factura NOT IN (SELECT factura_codigo FROM dbo.factura_contribuinte)
	/*update Invoice*/
	UPDATE dbo.factura SET dbo.factura.estado = inserted.Estado, dbo.factura.data_complecao = GETDATE() FROM inserted WHERE codigo = Factura AND inserted.Estado > 1
	UPDATE dbo.factura SET dbo.factura.estado = inserted.Estado FROM inserted WHERE codigo = Factura AND inserted.Estado < 2
	RETURN
END
GO



/*
Obtaining the next code from an Invoice
*/
CREATE PROC cliente.p_prox @codigo_anterior VARCHAR(12), @codigo_novo VARCHAR(12) OUTPUT AS
	DECLARE @ano_anterior INT
	SET @ano_anterior = CAST(SUBSTRING(@codigo_anterior,3,4) AS INT)
	
	DECLARE @ano_corrente INT
	SET @ano_corrente = YEAR(GETDATE())
	
	IF(@ano_corrente != @ano_anterior) BEGIN
		SET @codigo_novo = CONCAT(SUBSTRING(@codigo_anterior,1,2), RIGHT(@ano_corrente, 4), '-00000')
	END
	ELSE BEGIN
		SET @codigo_novo = CONCAT(SUBSTRING(@codigo_anterior,1,2), RIGHT(@ano_corrente, 4), '-', RIGHT('0000' + CAST((CAST(SUBSTRING(@codigo_anterior,8,5) AS INT) + 1) AS VARCHAR(5)), 5))
	END

	RETURN
GO

CREATE PROC cliente.p_proxFactura @codigo_novo VARCHAR(12) OUTPUT AS
	/*no transaction because only a single read is made*/
	DECLARE @codigo_anterior VARCHAR(12)
	SELECT TOP(1) @codigo_anterior = codigo FROM dbo.factura ORDER BY codigo DESC
	EXEC cliente.p_prox @codigo_anterior, @codigo_novo OUTPUT
	RETURN
GO

/*
Create an Invoice
proc p_criaFactura allows us to create an Invoice, without Items, but with the info about a Taxpayer's number (new or pre-existing)
*/
CREATE PROC cliente.p_criaFactura @contribuinte NUMERIC(9), @nome VARCHAR(20), @morada VARCHAR(256), @codigo VARCHAR(12) OUTPUT  AS
	BEGIN TRANSACTION
	/*Phantoms are not allowed here*/
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	
	EXEC cliente.p_proxFactura @codigo OUTPUT
	
	INSERT INTO dbo.factura(codigo) VALUES (@codigo)
	
	IF(@contribuinte IS NOT NULL) BEGIN
		IF(NOT EXISTS(SELECT * FROM dbo.contribuinte WHERE id = @contribuinte)) BEGIN
			INSERT INTO dbo.contribuinte(id,nome,morada) VALUES (@contribuinte,@nome,@morada)
		END
		INSERT INTO dbo.factura_contribuinte(factura_codigo, contribuinte_id) VALUES (@codigo, @contribuinte)
	END
	COMMIT
	RETURN
GO

/*
Obtain the next code from a Credit Note
*/
CREATE PROC cliente.p_proxNotaCredito @codigo_novo VARCHAR(12) OUTPUT AS
	/*no transaction because only a single read is made*/
	DECLARE @codigo_anterior VARCHAR(12)
	SELECT TOP(1) @codigo_anterior = codigo FROM dbo.nota_credito ORDER BY codigo DESC
	EXEC cliente.p_prox @codigo_anterior, @codigo_novo OUTPUT
	RETURN
GO

/*
Create a Credit Note
*/
CREATE PROC cliente.p_criaNotaCredito @factura_codigo VARCHAR(12), @codigo VARCHAR(12) OUTPUT AS
	BEGIN TRANSACTION
	/*Phantoms are not allowed here*/
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	
	EXEC cliente.p_proxNotaCredito @codigo OUTPUT
	
	INSERT INTO dbo.nota_credito(codigo, factura_codigo) VALUES (@codigo, @factura_codigo)
	COMMIT
	RETURN
GO

/*
Finish an insert of Items into the Invoice
*/
CREATE PROC cliente.p_facturaProforma @codigo VARCHAR(12) AS
	UPDATE dbo.factura SET estado = 1 WHERE codigo = @codigo AND estado = 0
	IF(@@ROWCOUNT != 1) BEGIN
		RAISERROR('Factura nao esta em actualizacao. Impossivel colocar em proforma', 15,1) 
		RETURN 
	END
	RETURN
GO

/*
Emit Invoice
*/
CREATE PROC cliente.p_facturaEmitir @codigo VARCHAR(12) AS
	UPDATE dbo.factura SET estado = 2, data_complecao = GETDATE() WHERE codigo = @codigo AND estado = 1
	IF(@@ROWCOUNT != 1) BEGIN
		RAISERROR('Factura nao esta em proforma. Impossivel emitir factura', 15,1)
		RETURN 
	END
	RETURN
GO

/*
Cancel Invoice
*/
CREATE PROC cliente.p_facturaAnular @codigo VARCHAR(12) AS
	UPDATE dbo.factura SET estado = 3, data_complecao = GETDATE() WHERE codigo = @codigo AND estado = 1
	IF(@@ROWCOUNT != 1) BEGIN
		RAISERROR('Factura nao esta em proforma. Impossivel anular factura', 15,1)
		RETURN 
	END
	RETURN
GO

/*
Emit a Credit Note
*/
CREATE PROC cliente.p_notaCreditoEmitir @codigo VARCHAR(12) AS
	BEGIN TRANSACTION
	/*The update has to be consistent with the information read*/
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
	IF(NOT EXISTS(SELECT * FROM dbo.nota_credito WHERE codigo = @codigo AND estado = 0)) BEGIN
		RAISERROR('Nota de Credito nao esta em actualizacao. Impossivel emitir.', 15,1)
		ROLLBACK TRANSACTION;  
		RETURN  
	END
	UPDATE dbo.nota_credito SET estado = 1, data_complecao = GETDATE() WHERE codigo = @codigo
	COMMIT
	RETURN
GO

/*
Function used to produce the listing of all Credit Notes emitted in a specific year
*/
CREATE FUNCTION cliente.f_listarNotasCredito(@ano int) RETURNS TABLE
    RETURN SELECT 
        codigo AS NotaCredito,
        factura_codigo AS Factura,
        estado AS Estado,
        data_criacao AS DataCriacao,
        data_complecao AS DataComplecao,
        preco AS Preco,
        iva AS IVA
    FROM dbo.nota_credito WHERE YEAR(data_criacao) = @ano
GO