--###### RUN IN ONE BATCH
insert into dbo.factura(codigo,estado,data_criacao)
values
	('FT2020-00001',0,DATEADD(minute,-30,GETDATE())),
	('FT2020-00002',0,DATEADD(minute,-25,GETDATE())),
	('FT2020-00003',0,DATEADD(minute,-10,GETDATE()))

insert into dbo.contribuinte(
	id,
	nome,
	morada
) 
values
	(123456789,'João Martins','R. Paulo Dias de Novais 26, Lisboa'),
	(123456788,'Rute Duarte','R. José Acúrcio das Neves 3, 1900-221 Lisboa'),
	(123456778,'Maria Costa','R. José Ricardo 2A, 1900-023 Lisboa')

insert into dbo.factura_contribuinte(factura_codigo,contribuinte_id) 
values
	('FT2020-00001',123456789),
	('FT2020-00002',123456788),
	('FT2020-00003',123456778)
insert into dbo.produto	(preco,iva,descricao)
values
	(12.32,.23,'Longsleeves vermelho - branco OUTONO/INVERNO'),
	(12.32,.23,'Longsleeves azul - branco OUTONO/INVERNO'),
	(12.32,.23,'Longsleeves verde - branco OUTONO/INVERNO'),
	(16.17,.23,'Calças de ganga preto - preto OUTONO/INVERNO'),
	(16.17,.23,'Calças de ganga azul - azul PRIMAVERA/VERAO'),
	(4.61,.23,'T-Shirt basic branco - cyan PRIMAVERA/VERAO')

insert into dbo.item(numero,quantidade,desconto,descricao,produto_sku,factura_codigo)
values
	(1,2,.0,null,1,'FT2020-00001'),
	(2,1,.10,null,6,'FT2020-00001'),
	(1,1,.0,null,3,'FT2020-00002'),
	(1,1,.15,null,5,'FT2020-00003'),
	(2,1,.0,null,2,'FT2020-00003')
--########################## 
--stop here and view result 
--run then view again
UPDATE dbo.factura			
   SET estado = 1
 WHERE codigo  IN('FT2020-00001','FT2020-00002');
/*UPDATE DBO.factura set estado = 1 where codigo = 'FT2020-00001'
UPDATE DBO.factura set estado = 1 where codigo = 'FT2020-00002'
UPDATE DBO.factura set estado = 1 where codigo = 'FT2020-00003'*/

--run then view again
UPDATE dbo.factura			
   SET estado = 2,data_complecao=GETDATE()
 WHERE codigo  IN('FT2020-00001','FT2020-00002');
/*UPDATE DBO.factura set estado = 2 where codigo = 'FT2020-00001'
UPDATE DBO.factura set estado = 2 where codigo = 'FT2020-00002'
UPDATE DBO.factura set estado = 2 where codigo = 'FT2020-00003'*/

--run then view result again
insert into dbo.nota_credito(codigo,estado,data_criacao,factura_codigo)
values ('NC2020-00001',0,DATEADD(minute,-2,GETDATE()),'FT2020-00001')
	
insert into dbo.devolucao(quantidade,item_numero,factura_codigo,nota_credito_codigo)
values (1,1,'FT2020-00001','NC2020-00001')
	
UPDATE DBO.nota_credito set estado = 1, data_complecao=GETDATE() where factura_codigo = 'FT2020-00001'
	
--######## CODE TO VIEW ALL DATA
	select * from dbo.factura
	select * from dbo.contribuinte
	select * from dbo.factura_contribuinte
	select * from dbo.produto
	select * from dbo.item order by factura_codigo
	select * from dbo.nota_credito
	select * from dbo.devolucao
	select * from dbo.change_log
