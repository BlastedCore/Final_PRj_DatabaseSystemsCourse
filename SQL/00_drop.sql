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