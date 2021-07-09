/*
IMPORTANT! 
BEFORE RUNNING TESTS YOU MUST SET UP THE DATABASE BY RUNNING THE FOLLOWING SCRIPTS:
00_drop, 01_create, 02_fill
*/

use L5DG_30
go
set nocount on
/*VARIABLES*/
DECLARE @errflg numeric
set @errflg=0
declare @errmsg varchar(400)
DECLARE @successmsg varchar(400)
declare @temp varchar(12)
declare @idp numeric

/*TESTS FOR TABLE dbo.factura*/
begin transaction 
/*--TEST 1: CREATE A NEW INVOICE WITH DUPLICATE CODE*/
	begin try
		insert into dbo.factura(codigo,estado,data_criacao)
		values('FT2020-10001',0,DATEADD(minute,-1,GETDATE())),('FT2020-10001',0,DATEADD(minute,-1,GETDATE())) 
	end try
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 1:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO CREATE AN INVOICE BECAUSE THERE IS ALREADY AN INVOICE WITH THAT CODE'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 1: FAILURE'+char(13)+'WAS ABLE TO CREATE AN INVOICE BUT IT SHOULND큈 BE POSSIBLE BECAUSE THERE IS ALREADY AN INVOICE WITH THAT CODE'+CHAR(13)
			raiserror(@errmsg,10,1)
		end

set @errflg=0
/*--TEST 2: CREATE A NEW INVOICE WITH NO ITEMS AND TEMIT IT*/
	begin try
		insert into dbo.factura(codigo,estado,data_criacao)
		values('FT2020-00010',0,DATEADD(minute,-1,GETDATE()))   
		UPDATE DBO.factura set estado = 1 where codigo = 'FT2020-00010' 
		UPDATE DBO.factura set estado = 2 where codigo = 'FT2020-00010' 
	end try
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 2:SUCCESS'+CHAR(13)+'WAS ABLE TO CREATE A NEW INVOICE WITH NO ITEMS BUT COULND큈 EMIT IT'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 2: FAILURE'+char(13)+'WAS ABLE TO CREATE A NEW INVOICE WITH NO ITEMS AND EMIT IT'+CHAR(13)
			raiserror(@errmsg,10,1)
		end

set @errflg=0
/*--TEST 3: CREATE A NEW INVOICE WITH AN INVALID STARTING DATE*/
	begin try
		insert into dbo.factura(codigo,estado,data_criacao)
		values('FT2020-00011',0,DATEADD(minute,+11,GETDATE()))
	end try
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 3:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO CREATE A NEW INVOICE WITH AN INVALID STARTING DATE'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 3: FAILURE'+char(13)+'WAS ABLE TO CREATE A NEW INVOICE WITH AN INVALID STARTING DATE'+CHAR(13)
			raiserror(@errmsg,10,1)
		end

set @errflg=0
/*--TEST 4: GIVING AN INVALID STATE TO AN INVOICE*/
	begin try
		insert into dbo.factura(codigo,estado,data_criacao)
		values('FT2020-00012',4,DATEADD(minute,-1,GETDATE()))       
	end try
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 4:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO GIVE AN INVALID STATE TO AN INVOICE'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 4: FAILURE'+char(13)+'WAS ABLE TO GIVE AN INVALID STATE TO AN INVOICE'+CHAR(13)
			raiserror(@errmsg,10,1)
		end

set @errflg=0
/*--TEST 5: GIVING VALUES TO PRICE AND IVA WITHOUT KNOWING THE RULES OF AN INVOICE*/
	begin try
		insert into dbo.factura(codigo,estado,data_criacao, preco, iva)
		values('FT2020-00014',0,DATEADD(minute,-1,GETDATE()),-1.0,-1.0)       
	end try
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 5:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO GIVE VALUES TO PRICE AND IVA WITHOUT KNOWING THE RULES OF AN INVOICE'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 5: FAILURE'+char(13)+'WAS ABLE TO GIVE VALUES TO PRICE AND IVA VIOLATING THE RULES OF AN INVOICE'+CHAR(13)
			raiserror(@errmsg,10,1)
		end

set @errflg=0
/*--TEST 6: CORRECT USE AND EMISSION OF AN INVOICE WITHOUT TAXPAYER*/
	begin try
		insert into dbo.factura(codigo,estado,data_criacao)
		values('FT2020-10000',0,DATEADD(minute,-1,GETDATE()))  
		insert into dbo.item(numero,quantidade,desconto,descricao,produto_sku,factura_codigo)
		values(	1,1,.0,null,6,'FT2020-10000') 
		update dbo.factura set estado=1 where codigo='FT2020-10000'
		update dbo.factura set estado=2,data_complecao=GETDATE() where codigo ='FT2020-10000'
	end try
	begin catch
		set @errflg=1
		set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 6: FAILURE'+char(13)+'WASN큈 ABLE TO USE AND EMIT CORRECTLY AN INVOICE WITHOUT TAXPAYER'+CHAR(13)
		raiserror(@errmsg,10,1)	
	end catch
	if(@errflg=0)
		begin
			set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 6:SUCCESS'+CHAR(13)+'WAS ABLE TO USE AND EMIT CORRECTLY AN INVOICE WITHOUT TAXPAYER'+CHAR(13)
			PRINT(@successmsg)
		end
rollback

set @errflg=0
/*TESTS FOR TABLE dbo.contribuinte*/
begin transaction 
/*--TEST 7: CREATE A NEW TAXPAYER WITH DUPLICATE ID*/
	begin try
		insert into dbo.contribuinte(id,nome,morada)
		values(123456789,'teste','avenida teste n�1')       
	end try
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 7:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO CREATE A NEW TAXPAYER WITH DUPLICATE ID'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 7: FAILURE'+char(13)+'WAS ABLE TO CREATE A NEW TAXPAYER WITH DUPLICATE ID'+CHAR(13)
			raiserror(@errmsg,10,1)
		end

set @errflg=0
/*--TEST 8: CREATE A NEW TAXPAYER WITH AN INVALID ID*/
	begin try
		insert into dbo.contribuinte(id,nome,morada)
		values(12345678910,'teste2','avenida teste n�2')  
	end try
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 8:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO CREATE A NEW TAXPAYER WITH AN INVALID ID'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 8: FAILURE'+char(13)+'WAS ABLE TO CREATE A NEW TAXPAYER WITH AN INVALID ID'+CHAR(13)
			raiserror(@errmsg,10,1)
		end

set @errflg=0
/*--TEST 9: CORRECT CREATION OF A TAXPAYER*/
	begin try
		insert into dbo.contribuinte(id,nome,morada)
		values(123456783,'teste3','avenida teste n�3')  
	end try
	begin catch
		set @errflg=1
		set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 9: FAILURE'+char(13)+'WASN큈 ABLE TO CREATE CORRECTLY A TAXPAYER'+CHAR(13)
		raiserror(@errmsg,10,1)	
	end catch
	if(@errflg=0)
		begin
			set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 9:SUCCESS'+CHAR(13)+'WAS ABLE TO USE CREATE CORRECTLY A TAXPAYER'+CHAR(13)
			PRINT(@successmsg)
		end
rollback

set @errflg = 0
/*TESTS FOR TABLE dbo.factura_contribuinte*/
begin transaction 
/*--TEST 10: CREATION OF A TAXPAYER TO INVOICE LINK WITH WRONG INPUTS*/
	begin try
		insert into dbo.factura_contribuinte(factura_codigo,contribuinte_id)
		values('FT2020-10001',111111113)       
	end try
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 10:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO CREATE A TAXPAYER TO INVOICE LINK WITH WRONG INPUTS'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 10: FAILURE'+char(13)+'WAS ABLE TO CREATE A TAXPAYER TO INVOICE LINK WITH WRONG INPUTS'+CHAR(13)
			raiserror(@errmsg,10,1)
		end

set @errflg=0
/*--TEST 11: CREATION OF A TAXPAYER TO INVOICE LINK WITH RIGHT INPUTS*/
	begin try
		insert into dbo.factura(codigo,estado,data_criacao)
		values('FT2020-10009',0,DATEADD(minute,-1,GETDATE()))  
		insert into dbo.factura_contribuinte(factura_codigo,contribuinte_id)
		values('FT2020-10009',123456789)  
	end try
	begin catch
		set @errflg=1
		set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 11: FAILURE'+char(13)+'WASN큈 ABLE TO CREATE A TAXPAYER TO INVOICE LINK WITH RIGHT INPUTS'+CHAR(13)
		raiserror(@errmsg,10,1)	
	end catch
	if(@errflg=0)
		begin
			set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 11:SUCCESS'+CHAR(13)+'WAS ABLE TO USE CREATE A TAXPAYER TO INVOICE LINK WITH RIGHT INPUTS'+CHAR(13)
			PRINT(@successmsg)
		end
rollback

set @errflg = 0
/*TESTS FOR TABLE dbo.produto*/
begin transaction 
/*--TEST 12: CREATION OF A PRODUCT WITH WRONG INPUTS*/
	begin try
		insert into dbo.produto(preco,iva,descricao)
		values(-1.0,-.23,'produto de teste')       
	end try
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 12:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO CREATE A PRODUCT WITH WRONG INPUTS'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 12: FAILURE'+char(13)+'WAS ABLE TO CREATE AN A PRODUCT WITH WRONG INPUTS'+CHAR(13)
			raiserror(@errmsg,10,1)
		end
rollback

	
set @errflg = 0
/*TESTS FOR TABLE dbo.item*/
begin transaction 
/*--TEST 13: CREATION OF A DUPLICATE ITEM*/
	begin try
		insert into dbo.item(numero,quantidade,desconto,descricao,produto_sku,factura_codigo)values(1,1,0.0,'item de teste2',2,'FT2020-00001')     
		insert into dbo.item(numero,quantidade,desconto,descricao,produto_sku,factura_codigo)values(1,2,0.0,'item de teste3',2,'FT2020-00001')       
	end try
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 13:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO CREATE A DUPLICATE ITEM'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 13: FAILURE'+char(13)+'WAS ABLE TO CREATE A DUPLICATE ITEM WITHIN THE SAME INVOICE'+CHAR(13)
			raiserror(@errmsg,10,1)
		end

set @errflg=0
/*--TEST 14: CREATION OF A NEGATIVE QUANTITY ITEM*/
	begin try
		insert into dbo.item(numero,quantidade,desconto,descricao,produto_sku,factura_codigo)values(3,-1,0.0,'item de teste3',2,'FT2020-00001')       
	end try
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 14:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO CREATE A NEGATIVE QUANTITY ITEM'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 14: FAILURE'+char(13)+'WAS ABLE TO CREATE A NEGATIVE QUANTITY ITEM'+CHAR(13)
			raiserror(@errmsg,10,1)
		end

set @errflg=0
/*--TEST 15: CREATING AN ITEM WITH TO A PRODUCT THAT DOESNT EXIST*/
	begin try
		insert into dbo.item(numero,quantidade,desconto,descricao,produto_sku,factura_codigo)values(4,1,0.0,'item de teste4',10,'FT2020-00001')       
	end try
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 15:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO CREATE AN ITEM WITH TO A PRODUCT THAT DOESNT EXIST'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 15: FAILURE'+char(13)+'WAS ABLE TO CREATE AN ITEM WITH TO A PRODUCT THAT DOESNT EXIST'+CHAR(13)
			raiserror(@errmsg,10,1)
		end

set @errflg=0
/*--TEST 16: CREATING AN ITEM WITH TO AN INVOICE THAT DOESNT EXIST*/
	begin try
		insert into dbo.item(numero,quantidade,desconto,descricao,produto_sku,factura_codigo)values(5,1,0.0,'item de teste5',4,'FT2020-00100')       
	end try
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 16:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO CREATE AN ITEM WITH TO AN INVOICE THAT DOESNT EXIST'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 16: FAILURE'+char(13)+'WAS ABLE TO CREATE AN ITEM WITH TO AN INVOICE THAT DOESNT EXIST'+CHAR(13)
			raiserror(@errmsg,10,1)
		end
rollback
	

set @errflg = 0
/*TESTS FOR TABLE dbo.nota_credito*/
begin transaction 
/*--TEST 17: CREATING A DUPLICATE CREDIT NOTE*/
	begin try
		insert into dbo.nota_credito(codigo,estado,data_criacao,factura_codigo)values('NC2020-00001',0,GETDATE(),'FT2020-00001')  
		insert into dbo.nota_credito(codigo,estado,data_criacao,factura_codigo)values('NC2020-00001',0,GETDATE(),'FT2020-00001')       
	end try
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 17:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO CREATE A DUPLICATE CREDIT NOTE'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 17: FAILURE'+char(13)+'WAS ABLE TO CREATE A DUPLICATE CREDIT NOTE'+CHAR(13)
			raiserror(@errmsg,10,1)
		end

set @errflg=0
/*--TEST 18: CREATING A CREDIT NOTE FOR AN INVOICE THAT HASN큈 BEEN EMITTED YET*/
	begin try
		insert into dbo.nota_credito(codigo,estado,data_criacao,factura_codigo)values('NC2020-00010',0,GETDATE(),'FT2020-00100')  
	end try
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 18:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO CREATE A CREDIT NOTE FOR AN INVOICE THAT HASN큈 BEEN EMITTED YET'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 18: FAILURE'+char(13)+'WAS ABLE TO CREATE A CREDIT NOTE FOR AN INVOICE THAT HASN큈 BEEN EMITTED YET'+CHAR(13)
			raiserror(@errmsg,10,1)
		end

set @errflg=0
/*--TEST 19: EMITTING AN EMPTY CREDIT NOTE*/
	begin try
		insert into dbo.nota_credito(codigo,estado,data_criacao,factura_codigo)values('NC2020-00003',0,GETDATE(),'FT2020-00002')  
		update dbo.nota_credito set estado=1 where codigo = 'NC2020-00003'
	end try
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 19:SUCCESS'+CHAR(13)+'WASN큈 ABLE EMIT AN EMPTY CREDIT NOTE'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 19: FAILURE'+char(13)+'WAS ABLE TO EMIT AN EMPTY CREDIT NOTE'+CHAR(13)
			raiserror(@errmsg,10,1)
		end

set @errflg=0
/*--TEST 20: CREATING AND GIVING WRONG VALUES TO A CREDIT NOTE*/
	begin try
		insert into dbo.nota_credito(codigo,estado,data_criacao,factura_codigo,preco,iva)values('NC2020-00006',0,GETDATE(), 'FT2020-00003',-1.0,-0.23)
	end try
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 20:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO CREATE AND GIVE WRONG VALUES TO A CREDIT NOTE'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 20: FAILURE'+char(13)+'WAS ABLE TO CREATE AND GIVE WRONG VALUES TO A CREDIT NOTE'+CHAR(13)
			raiserror(@errmsg,10,1)
		end
rollback

	

set @errflg = 0
/*TESTS FOR TABLE dbo.devolucao*/
begin transaction 
/*--TEST 21: RETURN AN ITEM TWICE IN CREDIT NOTE*/
	begin try
		insert into dbo.devolucao(quantidade,item_numero,factura_codigo,nota_credito_codigo)values(1,1,'FT2020-00001','NC2020-00001') 
		insert into dbo.devolucao(quantidade,item_numero,factura_codigo,nota_credito_codigo)values(1,1,'FT2020-00001','NC2020-00001')       
	end try
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 21:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO RETURN AN ITEM TWICE IN CREDIT NOTE'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 21: FAILURE'+char(13)+'WAS ABLE TO RETURN AN ITEM TWICE IN CREDIT NOTE'+CHAR(13)
			raiserror(@errmsg,10,1)
		end

set @errflg=0
/*--TEST 22: TRY TO RETURN A NON EXISTANT ITEM*/
	begin try
		insert into dbo.devolucao(quantidade,item_numero,factura_codigo,nota_credito_codigo)values(1,8,'FT2020-00001','NC2020-00001')       
	end try
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 22:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO RETURN A NON EXISTANT ITEM'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 22: FAILURE'+char(13)+'WAS ABLE TO RETURN A NON EXISTANT ITEM'+CHAR(13)
			raiserror(@errmsg,10,1)
		end

set @errflg=0
/*--TEST 23: TRY TO RETURN AN ITEM FROM A NON EXISTANT INVOICE*/
	begin try
		insert into dbo.devolucao(quantidade,item_numero,factura_codigo,nota_credito_codigo)values(1,1,'FT2020-00020','NC2020-00001')       
	end try
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 23:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO RETURN AN ITEM FROM A NON EXISTANT INVOICE'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 23: FAILURE'+char(13)+'WAS ABLE TO RETURN AN ITEM FROM A NON EXISTANT INVOICE'+CHAR(13)
			raiserror(@errmsg,10,1)
		end

set @errflg=0
/*--TEST 24: TRY TO RETURN AN ITEM AND REGISTER IT IN A NON EXISTANT NOTE CREDIT*/
	begin try
		insert into dbo.devolucao(quantidade,item_numero,factura_codigo,nota_credito_codigo)values(1,1,'FT2020-00001','NC2020-00011')       
	end try
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 24:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO RETURN AN ITEM AND REGISTER IT IN A NON EXISTANT NOTE CREDIT'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 24: FAILURE'+char(13)+'WAS ABLE TO RETURN AN ITEM AND REGISTER IT IN A NON EXISTANT NOTE CREDIT'+CHAR(13)
			raiserror(@errmsg,10,1)
		end

set @errflg=0
/*--TEST 25: TRY TO RETURN A NEGATIVE QUANTITY OF AN ITEM*/
	begin try
		insert into dbo.devolucao(quantidade,item_numero,factura_codigo,nota_credito_codigo)values(-1,2,'FT2020-00001','NC2020-0001')       
	end try
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 25:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO RETURN A NEGATIVE QUANTITY OF AN ITEM'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 25: FAILURE'+char(13)+'WAS ABLE TO RETURN A NEGATIVE QUANTITY OF AN ITEM'+CHAR(13)
			raiserror(@errmsg,10,1)
		end

set @errflg=0
/*--TEST 26: TRY TO RETURN AN EXCEEDING QUANTITY OF AN ITEM*/
	begin try
		insert into nota_credito(codigo,estado,data_criacao,factura_codigo) values('NC2020-00002',0,DATEADD(minute,-2,GETDATE()),'FT2020-00003')

		insert into dbo.devolucao(quantidade,item_numero,factura_codigo,nota_credito_codigo)values(2,1,'FT2020-00003','NC2020-0002')       
	end try
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 26:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO RETURN AN EXCEEDING QUANTITY OF AN ITEM'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 26: FAILURE'+char(13)+'WAS ABLE TO RETURN AN EXCEEDING QUANTITY OF AN ITEM'+CHAR(13)
			raiserror(@errmsg,10,1)
		end
rollback 

set @errflg=0
/*TESTS FOR TABLE dbo.change_log*/
/*In this instance we need to test the current creation of entries through the triggers and their results*/
begin transaction 
/*--TEST 27: CHECK IF LOG OF INVOICE EVENTS IS WORKING*/
	begin try
		insert into dbo.factura(codigo,estado,data_criacao)values('FT2020-00017',0,DATEADD(minute,-1,GETDATE()))
		if (not exists (select 1 from dbo.change_log where (evento = 'FACTURA CRIADA' and factura_codigo  = 'FT2020-00017' )))
			begin
				raiserror('',10,1)
			end 
		
		update dbo.factura set estado = 1 where codigo='FT2020-00017'
		if (not exists (select 1 from dbo.change_log where (evento = 'FACTURA ACTUALIZADA' and factura_codigo  = 'FT2020-00017' )))
			begin
				raiserror('',10,1)
			end 
	end try
	begin catch
		set @errflg=1
		set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 27: FAILURE'+char(13)+'LOG OF INVOICE EVENTS ISN큈 WORKING'+CHAR(13)
		raiserror(@errmsg,10,1)	
	end catch
	if(@errflg=0)
		begin
			set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 27:SUCCESS'+CHAR(13)+'LOG OF INVOICE EVENTS IS WORKING'+CHAR(13)
			PRINT(@successmsg)
		end
/*--TEST 27.1: CHECK IF LOG OF TAXPAYER TO INVOICE LINK EVENTS IS WORKING*/
	begin try
		insert into dbo.factura
			(	
				codigo,estado,data_criacao
			)
		values
			(
				'FT2020-00018',0,DATEADD(minute,-1,GETDATE())	
			)
		insert into dbo.contribuinte
			(
				id,nome,morada
			) 
		values
			(
				123451789,'teste trigger contri','contri'
			)
		insert into dbo.factura_contribuinte
			(
				factura_codigo,contribuinte_id
			)
		values
			(
				'FT2020-00018',123451789
			)
		if (not exists (select 1 from dbo.change_log where (evento = 'CONTRIBUINTE ADICIONADO A FACTURA' and factura_codigo  = 'FT2020-00018' )))
			begin
				raiserror('',10,1)
			end 		
	end try
	begin catch
		set @errflg=1
		set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 27.1: FAILURE'+char(13)+'LOG OF TAXPAYER TO INVOICE LINK EVENTS ISN큈 WORKING'+CHAR(13)
		raiserror(@errmsg,10,1)	
	end catch
	if(@errflg=0)
		begin
			set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 27.1:SUCCESS'+CHAR(13)+'LOG OF TAXPAYER TO INVOICE LINK EVENTS IS WORKING'+CHAR(13)
			PRINT(@successmsg)
		end
/*--TEST 27.2: CHECK IF LOG OF ITEM IN INVOICE EVENTS IS WORKING*/
	begin try
		insert into dbo.item
			(	
				numero,quantidade,desconto,descricao,produto_sku,factura_codigo
			)
		values
			(
				3,1,.0,null,4,'FT2020-00003'
			)	
		if (not exists (select 1 from dbo.change_log join item on change_log.factura_codigo  = item.factura_codigo where (evento = 'ITEM ADICIONADO' and change_log.factura_codigo='FT2020-00003' and item.numero=3 and item.produto_sku=4)))
			begin
				raiserror('',10,1)
			end 	

		delete from item where factura_codigo = 'FT2020-00003' and numero = 3
		if (not exists (select 1 from dbo.change_log  where (evento = 'ITEM REMOVIDO' and change_log.factura_codigo='FT2020-00003')))
			begin
				if (exists (select 1 from dbo.item  where  numero=3 and factura_codigo='FT2020-00003'))
					begin
						raiserror('',10,1)
					end
			end 	
		
	end try
	begin catch
		set @errflg=1
		set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 27.2: FAILURE'+char(13)+'LOG OF ITEM IN INVOICE EVENTS ISN큈 WORKING'+CHAR(13)
		raiserror(@errmsg,10,1)	
	end catch
	if(@errflg=0)
		begin
			set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 27.2:SUCCESS'+CHAR(13)+'LOG OF ITEM IN INVOICE EVENTS IS WORKING'+CHAR(13)
			PRINT(@successmsg)
		end
/*--TEST 27.3: CHECK IF LOG OF CREDIT NOTE OF AN INVOICE EVENTS IS WORKING*/
	begin try
		insert into dbo.nota_credito
			(	
				codigo,estado,data_criacao,factura_codigo
			)
		values
			(
				'NC2020-00010',0,DATEADD(minute,-2,GETDATE()),'FT2020-00002'
			)
		if (not exists (select 1 from dbo.change_log  where (evento = 'NOTA DE CREDITO CRIADA' and change_log.factura_codigo='FT2020-00010' )))
			begin
				raiserror('',10,1)
			end 	

		insert into dbo.devolucao values (1,1,'FT2020-00002','NC2020-00010')
		update dbo.nota_credito set estado = 1,data_complecao=GETDATE() where  codigo='NC2020-00010'
		
		if (not exists (select 1 from dbo.change_log  where (evento = 'NOTA DE CREDITO ACTUALIZADA' and change_log.factura_codigo='FT2020-00010')))
			begin			
				raiserror('',10,1)	
			end 	
	end try
	begin catch
		set @errflg=1
		set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 27.3: FAILURE'+char(13)+'LOG OF CREDIT NOTE OF AN INVOICE EVENTS ISN큈 WORKING'+CHAR(13)
		raiserror(@errmsg,10,1)	
	end catch
	if(@errflg=0)
		begin
			set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 27.3:SUCCESS'+CHAR(13)+'LOG OF CREDIT NOTE OF AN INVOICE EVENTS IS WORKING'+CHAR(13)
			PRINT(@successmsg)
		end
/*--TEST 28: CHECK IF LOG OF RETURN OF ITEMS EVENTS IS WORKING*/
	begin try
		insert into dbo.nota_credito
			(	
				codigo,estado,data_criacao,factura_codigo
			)
		values
			(
				'NC2020-00011',0,DATEADD(minute,-2,GETDATE()),'FT2020-00001'
			)
		insert into dbo.devolucao
			(	
				quantidade,item_numero,factura_codigo,nota_credito_codigo
			)
		values
			(	
				1,1,'FT2020-00001','NC2020-00011'
			)	
		if (not exists (select 1 from dbo.change_log where evento = 'ITEM A DEVOLVER ADICIONADO' and change_log.factura_codigo='FT2020-00001'))
			begin
				raiserror('',10,1)
			end 	

		delete from devolucao where factura_codigo = 'FT2020-00001' and item_numero=1 and nota_credito_codigo='NC2020-00011'
		if (not exists (select 1 from dbo.change_log where evento = 'ITEM A DEVOLVER REMOVIDO' and change_log.factura_codigo='FT2020-00001'))
			begin
				raiserror('',10,1)	
			end 	
	end try
	begin catch
		set @errflg=1
		set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 28: FAILURE'+char(13)+'LOG OF RETURN OF ITEMS EVENTS ISN큈 WORKING'+CHAR(13)
		raiserror(@errmsg,10,1)	
	end catch
	if(@errflg=0)
		begin
			set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 28:SUCCESS'+CHAR(13)+'LOG OF RETURN OF ITEMS EVENTS IS WORKING'+CHAR(13)
			PRINT(@successmsg)
		end
rollback

set @errflg=0
/*TESTS FOR VALUE UPDATE TRIGGRES*/
/*In this instance we test the triggers that allow for an automatic update of values in the invoices and credit notes*/
begin transaction
/*--TEST 29: CHECK IF AUTOMATIC UPDATE OF VALUES IN INCOICE IS WORKING*/
	begin try
		insert into dbo.factura
			(	
				codigo,estado,data_criacao
			)
		values
			(
				'FT2020-00019',0,DATEADD(minute,-1,GETDATE())	
			)
		insert into dbo.item
			(	
				numero,quantidade,desconto,descricao,produto_sku,factura_codigo
			)
		values
			(
				1,3,.0,null,1,'FT2020-00019'
			)	
		update dbo.factura set estado = 1 where codigo = 'FT2020-00019'
		if (not exists (select 1 from dbo.change_log where (evento = 'FACTURA VALOR ACTUALIZADO' and factura_codigo  = 'FT2020-00019' )))
			begin
				raiserror('',10,1)
			end 
		update dbo.factura set estado = 2,data_complecao=GETDATE() where codigo = 'FT2020-00019'
		if (not exists (select 1 from dbo.change_log where (evento = 'FACTURA DATA_COMPLECAO INSERIDA' and factura_codigo  = 'FT2020-00019' )))
			begin
				raiserror('',10,1)
			end 
	end try
	begin catch
		set @errflg=1
		set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 29: FAILURE'+char(13)+'AUTOMATIC UPDATE OF VALUES IN INCOICE ISN큈 WORKING'+CHAR(13)
		raiserror(@errmsg,10,1)	
	end catch
	if(@errflg=0)
		begin
			set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 29:SUCCESS'+CHAR(13)+'AUTOMATIC UPDATE OF VALUES IN INCOICE IS WORKING'+CHAR(13)
			PRINT(@successmsg)
		end
/*--TEST 30: CHECK IF AUTOMATIC UPDATE OF VALUES IN CREDIT NOTE IS WORKING*/
	begin try
		insert into dbo.factura
			(	
				codigo,estado,data_criacao
			)
		values
			(
				'FT2020-00031',0,DATEADD(minute,-1,GETDATE())	
			)
		insert into dbo.item
			(	
				numero,quantidade,desconto,descricao,produto_sku,factura_codigo
			)
		values
			(
				1,3,.0,null,1,'FT2020-00031'
			)	
		update dbo.factura set estado = 1 where codigo = 'FT2020-000311' 
		update dbo.factura set estado = 2,data_complecao=GETDATE() where codigo = 'FT2020-00031'
		insert into dbo.nota_credito
			(	
				codigo,estado,data_criacao,factura_codigo
			)
		values
			(
				'NC2020-00012',0,DATEADD(minute,-2,GETDATE()),'FT2020-00031'
			)
		insert into dbo.devolucao
			(	
				quantidade,item_numero,factura_codigo,nota_credito_codigo
			)
		values
			(	
				1,1,'FT2020-00031','NC2020-00012'
			)	
		update dbo.nota_credito set estado = 1,data_complecao=GETDATE() where codigo = 'NC2020-00012'
		if (not exists (select 1 from dbo.change_log where (evento = 'NOTA CREDITO VALOR ATUALIZADO' and factura_codigo  = 'FT2020-00031' )))
			begin
				raiserror('',10,1)
			end 
	end try
	begin catch
		set @errflg=1
		--set @errmsg=ERROR_MESSAGE()
		set @errmsg= '#########################################################################'+CHAR(13)+'--TEST 30: FAILURE'+char(13)+'AUTOMATIC UPDATE OF VALUES IN CREDIT NOTE ISN큈 WORKING'+CHAR(13)
		raiserror(@errmsg,10,1)	
	end catch
	if(@errflg=0)
		begin
			set @successmsg = '#########################################################################'+CHAR(13)+'--TEST 30:SUCCESS'+CHAR(13)+'AUTOMATIC UPDATE OF VALUES IN CREDIT NOTE IS WORKING'+CHAR(13)
			PRINT(@successmsg)
		end
rollback


/*TESTS FOR API*/
set @errflg=0
begin transaction
/*--API TEST 1: CLIENT TRIES TO ALTER SOMETHING OTHER THAN THE DESCRIPTION OF AN ITEM THAT HAS BEEN SOLD*/
	begin try
		insert into dbo.factura(codigo,estado,data_criacao)values('FT2020-01005',0,DATEADD(minute,-1,GETDATE())) 
		insert into dbo.produto(preco,IVA,Descricao) values(15,0.23,'Camisola de noite Azul - Branco')   
		select @idp = SCOPE_IDENTITY()
		insert into dbo.item(numero,quantidade,desconto,descricao,produto_sku,factura_codigo) values(1,1,0,'',@idp,'FT2020-01005')
		update cliente.produto set Preco=10,IVA=0.39 where sku=@idp
	end try
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--API TEST 1:SUCCESS'+CHAR(13)+' CLIENT TRIES TO ALTER SOMETHING OTHER THAN THE DESCRIPTION OF AN ITEM THAT HAS BEEN SOLD, AND FAILS BECAUSE THEY ARE NOT ALLOWED TO DO THAT'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--API TEST 1: FAILURE'+char(13)+'CLIENT WAS ABLE TO ALTER THE PRICE OF A PRODUCT ALREADY SOLD'+CHAR(13)
			raiserror(@errmsg,10,1)	
		end
rollback;

set @errflg=0
begin transaction
/*--API TEST 2: CLIENT TRIES TO ALTER THE DESCRIPTION OF AN ITEM THAT HAS BEEN SOLD*/
	begin try
		insert into dbo.factura(codigo,estado,data_criacao)values('FT2020-01006',0,DATEADD(minute,-1,GETDATE())) 
		insert into dbo.produto(preco,IVA,Descricao) values(15,0.23,'Camisola de noite Verde - Branco')   
		select @idp = SCOPE_IDENTITY()
		insert into dbo.item(numero,quantidade,desconto,descricao,produto_sku,factura_codigo) values(1,1,0,'',@idp,'FT2020-01006')
		update cliente.produto set Descricao='produto de teste2' where SKU=@idp	
	end try
	begin catch
		set @errflg=1
		set @errmsg= '#########################################################################'+CHAR(13)+'--API TEST 2: FAILURE'+char(13)+'CLIENT WAS NOT ABLE TO UPDATE AN ITEM큆 DESCRIPTION THROUGH THE CLIENT SIDE'+CHAR(13)
		raiserror(@errmsg,10,1)		
	end catch
	if(@errflg=0)
		begin
			set @successmsg = '#########################################################################'+CHAR(13)+'--API TEST 2:SUCCESS'+CHAR(13)+'CORRECT UPDATE OF AN ITEM큆 DESCRIPTION THROUGH THE CLIENT SIDE'+CHAR(13)
			PRINT(@successmsg)
		end
rollback

set @errflg=0
begin transaction
/*--API TEST 3: OBTAINING THE NEXT CODE FROM AN INVOICE*/
	begin try 

		insert into dbo.factura(codigo,estado,data_criacao)values('FT2020-01001',0,DATEADD(minute,-1,GETDATE())) 
		insert into dbo.factura(codigo,estado,data_criacao)values('FT2020-01004',0,DATEADD(minute,-1,GETDATE())) 
		declare @ant varchar(12)
		exec cliente.p_prox @codigo_anterior = 'FT2020-01001',@codigo_novo = @ant output;
		select @ant as NEXT_AVAILABLE
		
	end try 
	begin catch
		set @errflg=1
		set @errmsg= '#########################################################################'+CHAR(13)+'--API TEST 3: FAILURE'+char(13)+'WASN큈 ABLE TO OBTAIN THE NEXT CODE FROM AN INVOICE'+CHAR(13)
		raiserror(@errmsg,10,1)	
	end catch
	if(@errflg=0)
		begin
			set @successmsg = '#########################################################################'+CHAR(13)+'--API TEST 3:SUCCESS'+CHAR(13)+'WAS ABLE TO OBTAIN THE NEXT CODE FROM AN INVOICE'+CHAR(13)
			PRINT(@successmsg)
		end
rollback

set @errflg=0
begin transaction
/*--API TEST 4: CREATE AN INVOICE FROM CLIENT SIDE WRONG INFO*/
	begin try 
		EXEC cliente.p_criaFactura @contribuinte=0000000000,@nome='teste boy',@morada='proc teste'
	end try 
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--API TEST 4:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO CREATE AN INVOICE DUE TO INCORRECT INPUT'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--API TEST 4: FAILURE'+char(13)+'WAS ABLE TO CREATE AN INVOICE WITH INCORRECT INPUT'+CHAR(13)
			raiserror(@errmsg,10,1)
		end
rollback

set @errflg=0
begin transaction
/*--API TEST 5: CREATE AN INVOICE FROM CLIENT SIDE*/
	begin try 
		EXEC cliente.p_criaFactura @contribuinte=111122222,@nome='teste boy',@morada='proc teste',@codigo=@temp
	end try 
	begin catch
		set @errflg=1
		set @errmsg= '#########################################################################'+CHAR(13)+'--API TEST 5: FAILURE'+char(13)+'WASN큈 ABLE TO CREATE AN INVOICE FROM CLIENT SIDE'+CHAR(13)
		raiserror(@errmsg,10,1)	
	end catch
	if(@errflg=0)
		begin
			set @successmsg = '#########################################################################'+CHAR(13)+'--API TEST 5:SUCCESS'+CHAR(13)+'CORRECT INPUT ALLOWS TO CREATE AN INVOICE FROM CLIENT SIDE'+CHAR(13)
			PRINT(@successmsg)
		end
rollback

set @errflg=0
begin transaction
/*--API TEST 6: CREATE A CREDIT NOTE FROM CLIENT SIDE WRONG INFO*/
	begin try 
		EXEC cliente.p_criaNotaCredito @factura_codigo = 'FT2020-01001'
	end try 
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--API TEST 6:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO CREATE A CREDIT NOTE FROM CLIENT SIDE DUE TO WRONG INFO'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--API TEST 6: FAILURE'+char(13)+'WAS ABLE TO CREATE A CREDIT NOTE FROM CLIENT SIDE EVEN WITH WRONG INFO'+CHAR(13)
			raiserror(@errmsg,10,1)
		end
rollback

set @errflg=0
begin transaction
/*--API TEST 7: CREATE A CREDIT NOTE FROM CLIENT SIDE BUT IT HASNT BEEN EMITTED YET*/
	begin try 
		insert into dbo.factura(codigo,estado,data_criacao)values('FT2020-01001',0,DATEADD(minute,-1,GETDATE())) 
		EXEC cliente.p_criaNotaCredito @factura_codigo = 'FT2020-01001'
	end try 
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--API TEST 7:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO CREATE A CREDIT NOTE FROM CLIENT SIDE BECAUSE IT HASNT BEEN EMITTED YET'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--API TEST 7: FAILURE'+char(13)+'WAS ABLE TO CREATE A CREDIT NOTE FROM CLIENT SIDE BUT IT HASNT BEEN EMITTED YET'+CHAR(13)
			raiserror(@errmsg,10,1)
		end
rollback
set @errflg=0
begin transaction
/*--API TEST 8: CREATE A CREDIT NOTE FROM CLIENT SIDE*/
	begin try 
		EXEC cliente.p_criaNotaCredito @factura_codigo = 'FT2020-00001',@codigo= output
	end try 
	begin catch
		set @errflg=1
		set @errmsg= '#########################################################################'+CHAR(13)+'--API TEST 8: FAILURE'+char(13)+'WASN큈 ABLE TO CREATE A CREDIT NOTE FROM CLIENT SIDE'+CHAR(13)
		raiserror(@errmsg,10,1)	
	end catch
	if(@errflg=0)
		begin
			set @successmsg = '#########################################################################'+CHAR(13)+'--API TEST 8:SUCCESS'+CHAR(13)+'WAS ABLE TO CREATE A CREDIT NOTE FROM CLIENT SIDE'+CHAR(13)
			PRINT(@successmsg)
		end
rollback

set @errflg=0
begin transaction
/*--API TEST 9: ADD ITEMS TO AN INVOICE, DUPLICATE NUM*/
	begin try 
		insert into dbo.factura(codigo,estado,data_criacao)values('FT2020-01001',0,DATEADD(minute,-1,GETDATE())) 
		insert into dbo.produto(preco,IVA,Descricao) values(15,0.23,'Camisola de noite Azul - Branco')   
		select @idp = SCOPE_IDENTITY()
		insert into cliente.item (Factura,Produto,Numero,Quantidade,Desconto,Descricao) values ('FT2020-01001',@idp,1,1,0,'')
		insert into cliente.item (Factura,Produto,Numero,Quantidade,Desconto,Descricao) values ('FT2020-01001',@idp,1,1,0,'')
	end try 
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--API TEST 9:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO ADD ITEMS TO AN INVOICE BECAUSE THERE IS ALREADY AN ITEM RELATED TO THAT PRODUCT IN THE INVOICE'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--API TEST 9: FAILURE'+char(13)+'WAS ABLE TO ADD ITEMS TO AN INVOICE EVEN THOUGH THERE IS ALREADY AN ITEM RELATED TO THAT PRODUCT IN THE INVOICE'+CHAR(13)
			raiserror(@errmsg,10,1)
		end
rollback

set @errflg=0
begin transaction
/*--API TEST 10: ADD ITEMS TO AN INVOICE*/
	begin try 
		insert into dbo.factura(codigo,estado,data_criacao)values('FT2020-01001',0,DATEADD(minute,-1,GETDATE())) 

		insert into dbo.produto(preco,IVA,Descricao) values(15,0.23,'Camisola de noite Azul - Branco')
		select @idp = SCOPE_IDENTITY()
		insert into cliente.item (Factura,Produto,Numero,Quantidade,Desconto,Descricao) values ('FT2020-01001',@idp,1,1,0,'')

		insert into dbo.produto(preco,IVA,Descricao) values(16,0.23,'Camisola de noite VERDE - Branco')   
		select @idp = SCOPE_IDENTITY()
		insert into cliente.item (Factura,Produto,Numero,Quantidade,Desconto,Descricao) values ('FT2020-01001',@idp,2,1,0,'')

	end try 
	begin catch
		set @errflg=1
		set @errmsg= '#########################################################################'+CHAR(13)+'--API TEST 10: FAILURE'+char(13)+'WASN큈 ABLE TO ADD ITEMS TO AN INVOICE'+CHAR(13)
		raiserror(@errmsg,10,1)	
	end catch
	if(@errflg=0)
		begin
			set @successmsg = '#########################################################################'+CHAR(13)+'--API TEST 10:SUCCESS'+CHAR(13)+'WAS ABLE TO ADD ITEMS TO AN INVOICE'+CHAR(13)
			PRINT(@successmsg)
		end
rollback

set @errflg=0
begin transaction
/*--API TEST 11: REMOVE ITEMS FROM AN INVOICE*/
	begin try 
		insert into dbo.factura(codigo,estado,data_criacao)values('FT2020-01001',0,DATEADD(minute,-1,GETDATE())) 

		insert into dbo.produto(preco,IVA,Descricao) values(15,0.23,'Camisola de noite Azul - Branco')
		select @idp = SCOPE_IDENTITY()
		insert into cliente.item (Factura,Produto,Numero,Quantidade,Desconto,Descricao) values ('FT2020-01001',@idp,1,1,0,'')
		
		delete from cliente.item where Produto=@idp and Factura='FT2020-01001'

	end try 
	begin catch
		set @errflg=1
		set @errmsg= '#########################################################################'+CHAR(13)+'--API TEST 11: FAILURE'+char(13)+'WASN큈 ABLE TO REMOVE ITEMS FROM AN INVOICE'+CHAR(13)
		raiserror(@errmsg,10,1)	
	end catch
	if(@errflg=0)
		begin
			set @successmsg = '#########################################################################'+CHAR(13)+'--API TEST 11:SUCCESS'+CHAR(13)+'WAS ABLE TO REMOVE AN ITEM FROM AN INVOICE'+CHAR(13)
			PRINT(@successmsg)
		end
rollback

set @errflg=0
begin transaction
/*--API TEST 12: UPDATE THE VALUES OF AN INVOICE AND ITS STATE(0 then 1 then 2), NO ITEMS*/
	begin try 
		insert into dbo.factura(codigo,estado,data_criacao)values('FT2020-01001',0,DATEADD(minute,-1,GETDATE())) 

		exec cliente.p_facturaProforma @codigo = 'FT2020-01001'

		exec cliente.p_facturaEmitir @codigo = 'FT2020-01001'

	end try 
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--API TEST 12:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO UPDATE THE VALUES OF AN INVOICE AND ITS STATE(0 then 1 then 2) BECAUSE THE INVOICE HAS NO ITEMS BEFORE THE UPDATE'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--API TEST 12: FAILURE'+char(13)+'WAS ABLE TO UPDATE THE VALUES OF AN INVOICE AND ITS STATE(0 then 1 then 2) EVEN THOUGH THE INVOICE HAS NO ITEMS BEFORE THE UPDATE'+CHAR(13)
			raiserror(@errmsg,10,1)
		end
rollback

set @errflg=0
begin transaction
/*--API TEST 13: UPDATE THE VALUES OF AN INVOICE AND ITS STATE(0 then 1 then 2)*/
	begin try 
		insert into dbo.factura(codigo,estado,data_criacao)values('FT2020-01001',0,DATEADD(minute,-1,GETDATE())) 

		insert into dbo.produto(preco,IVA,Descricao) values(15,0.23,'Camisola de noite Azul - Branco')
		select @idp = SCOPE_IDENTITY()
		insert into cliente.item (Factura,Produto,Numero,Quantidade,Desconto,Descricao) values ('FT2020-01001',@idp,1,1,0,'')

		insert into dbo.produto(preco,IVA,Descricao) values(16,0.23,'Camisola de noite VERDE - Branco')   
		select @idp = SCOPE_IDENTITY()
		insert into cliente.item (Factura,Produto,Numero,Quantidade,Desconto,Descricao) values ('FT2020-01001',@idp,2,1,0,'')

		exec cliente.p_facturaProforma @codigo = 'FT2020-01001'

		exec cliente.p_facturaEmitir @codigo = 'FT2020-01001'

	end try 
	begin catch
		set @errflg=1
		set @errmsg= '#########################################################################'+CHAR(13)+'--API TEST 13: FAILURE'+char(13)+'WASN큈 ABLE TO UPDATE THE VALUES OF AN INVOICE AND ITS STATE(0 then 1 then 2), EITHER BECAUSE THE INVOICE DOESN큈 EXIST, IT DOESN큈 HAVE ITEMS AND/OR IS ALREADY EMITTED'+CHAR(13)
		raiserror(@errmsg,10,1)	
	end catch
	if(@errflg=0)
		begin
			set @successmsg = '#########################################################################'+CHAR(13)+'--API TEST 13:SUCCESS'+CHAR(13)+'WAS ABLE TO UPDATE THE VALUES OF AN INVOICE AND ITS STATE(0 then 1 then 2), BECAUSE THE INVOICE EXISTS, IT HAS ITEMS AND ISN큈 ALREADY EMITTED'+CHAR(13)
			PRINT(@successmsg)
		end
rollback

set @errflg=0
begin transaction
/*--API TEST 14: CREATE LISTING OF ALL CREDIT NOTES OF A SPECIFIC YEAR, WRONG INPUT*/
	begin try 
		
		select NotaCredito erroPrevistoTeste14 from cliente.f_listarNotasCredito('a') 

	end try 
	begin catch
		set @errflg=1
		set @successmsg = '#########################################################################'+CHAR(13)+'--API TEST 14:SUCCESS'+CHAR(13)+'WASN큈 ABLE TO CREATE LISTING OF ALL CREDIT NOTES OF A SPECIFIC YEAR BECAUSE INPUT IS WRONG'+CHAR(13)
		PRINT(@successmsg)
	end catch
	if(@errflg=0)
		begin
			set @errmsg= '#########################################################################'+CHAR(13)+'--API TEST 12: FAILURE'+char(13)+'WAS ABLE TO CREATE LISTING OF ALL CREDIT NOTES OF A SPECIFIC YEAR WITH A WRONG INPUT'+CHAR(13)
			raiserror(@errmsg,10,1)
		end
rollback

set @errflg=0
begin transaction
/*--API TEST 15: CREATE AND EMIT AN INVOICE, THEN CREATE AND EMIT A CREDIT NOTE WITH CORRECT INFO, FINALLY SHOW LIST OF ALL CREDIT NOTES FOR 2020*/
	begin try 
		
		insert into dbo.factura(codigo,estado,data_criacao)values('FT2020-01001',0,DATEADD(year,-1,GETDATE())) 
		insert into cliente.item (Factura,Produto,Numero,Quantidade,Desconto,Descricao) values ('FT2020-01001',1,1,1,0,'')

		exec cliente.p_facturaProforma @codigo = 'FT2020-01001'
		exec cliente.p_facturaEmitir @codigo = 'FT2020-01001'

		exec cliente.p_criaNotaCredito @factura_codigo = 'FT2020-01001', @codigo = @temp OUTPUT
		insert into cliente.devolucao(Factura,NotaCredito,Numero,Quantidade)values('FT2020-01001',@temp,1,1)
		exec cliente.p_notaCreditoEmitir @codigo = @temp
		select NotaCredito,DataComplecao,Preco,IVA  from cliente.f_listarNotasCredito(2020) 

	end try 
	begin catch
		set @errflg=1
		set @errmsg= '#########################################################################'+CHAR(13)+'--API TEST 15: FAILURE'+char(13)+'WASN큈 ABLE TO CREATE NOR EMIT AN INVOICE, OR CREATE AND EMIT A CREDIT NOTE, SO AN ERROR OCURRS'+CHAR(13)
		raiserror(@errmsg,10,1)	
	end catch
	if(@errflg=0)
		begin
			set @successmsg = '#########################################################################'+CHAR(13)+'--API TEST 15:SUCCESS'+CHAR(13)+'WAS ABLE TO CREATE AND EMIT AN INVOICE, THEN CREATE AND EMIT A CREDIT NOTE WITH CORRECT INFO, FINALLY IT큆 SHOWN A LIST OF ALL CREDIT NOTES FOR 2020, RESULT FOUND IN RESULTS WINDOW'+CHAR(13)
			PRINT(@successmsg)
		end
rollback

set @errflg=0
begin transaction
/*--API TEST 16: VIEW WITH ALL INVOICE AND TAXPAYERS INFO THAT ALLOWS STATE UPDATE*/
	begin try 
		UPDATE cliente.factura set Estado=1 where Factura = 'FT2020-00003'
		if(not exists(select 1 from cliente.factura where Factura = 'FT2020-00003' and Estado = 1))
		begin
			raiserror('',15,1)
		end
		select * from cliente.factura
	end try 
	begin catch
		set @errflg=1
		set @errmsg= '#########################################################################'+CHAR(13)+'--API TEST 16: FAILURE'+char(13)+'WASN큈 ABLE TO VIEW WITH ALL INVOICE AND TAXPAYERS INFO THAT ALLOWS STATE UPDATE'+CHAR(13)
		raiserror(@errmsg,10,1)	
	end catch
	if(@errflg=0)
		begin
			set @successmsg = '#########################################################################'+CHAR(13)+'--API TEST 16:SUCCESS'+CHAR(13)+'VIEW WITH ALL INVOICE AND TAXPAYERS INFO THAT ALLOWS STATE UPDATE'+CHAR(13)
			PRINT(@successmsg)
		end
rollback
set @errflg=0

