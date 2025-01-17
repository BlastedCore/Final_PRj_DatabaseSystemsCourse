﻿//------------------------------------------------------------------------------
// <auto-generated>
//    This code was generated from a template.
//
//    Manual changes to this file may cause unexpected behavior in your application.
//    Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace EFModel
{
    using System;
    using System.Data.Entity;
    using System.Data.Entity.Infrastructure;
    using System.Data.Objects;
    using System.Data.Objects.DataClasses;
    using System.Linq;
    
    public partial class L5DG_30_connection : DbContext
    {
        public L5DG_30_connection()
            : base("name=L5DG_30_connection")
        {
        }
    
        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            throw new UnintentionalCodeFirstException();
        }
    
        public DbSet<change_log> change_log { get; set; }
        public DbSet<contribuinte> contribuintes { get; set; }
        public DbSet<devolucao> devolucaos { get; set; }
        public DbSet<factura> facturas { get; set; }
        public DbSet<factura_contribuinte> factura_contribuinte { get; set; }
        public DbSet<item> items { get; set; }
        public DbSet<nota_credito> nota_credito { get; set; }
        public DbSet<produto> produtoes { get; set; }
    
        [EdmFunction("L5DG_30_connection", "f_listarNotasCredito")]
        public virtual IQueryable<f_listarNotasCredito_Result> f_listarNotasCredito(Nullable<int> ano)
        {
            var anoParameter = ano.HasValue ?
                new ObjectParameter("ano", ano) :
                new ObjectParameter("ano", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.CreateQuery<f_listarNotasCredito_Result>("[L5DG_30_connection].[f_listarNotasCredito](@ano)", anoParameter);
        }
    
        public virtual int p_criaFactura(Nullable<decimal> contribuinte, string nome, string morada, ObjectParameter codigo)
        {
            var contribuinteParameter = contribuinte.HasValue ?
                new ObjectParameter("contribuinte", contribuinte) :
                new ObjectParameter("contribuinte", typeof(decimal));
    
            var nomeParameter = nome != null ?
                new ObjectParameter("nome", nome) :
                new ObjectParameter("nome", typeof(string));
    
            var moradaParameter = morada != null ?
                new ObjectParameter("morada", morada) :
                new ObjectParameter("morada", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("p_criaFactura", contribuinteParameter, nomeParameter, moradaParameter, codigo);
        }
    
        public virtual int p_criaNotaCredito(string factura_codigo, ObjectParameter codigo)
        {
            var factura_codigoParameter = factura_codigo != null ?
                new ObjectParameter("factura_codigo", factura_codigo) :
                new ObjectParameter("factura_codigo", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("p_criaNotaCredito", factura_codigoParameter, codigo);
        }
    
        public virtual int p_facturaAnular(string codigo)
        {
            var codigoParameter = codigo != null ?
                new ObjectParameter("codigo", codigo) :
                new ObjectParameter("codigo", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("p_facturaAnular", codigoParameter);
        }
    
        public virtual int p_facturaEmitir(string codigo)
        {
            var codigoParameter = codigo != null ?
                new ObjectParameter("codigo", codigo) :
                new ObjectParameter("codigo", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("p_facturaEmitir", codigoParameter);
        }
    
        public virtual int p_facturaProforma(string codigo)
        {
            var codigoParameter = codigo != null ?
                new ObjectParameter("codigo", codigo) :
                new ObjectParameter("codigo", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("p_facturaProforma", codigoParameter);
        }
    
        public virtual int p_notaCreditoEmitir(string codigo)
        {
            var codigoParameter = codigo != null ?
                new ObjectParameter("codigo", codigo) :
                new ObjectParameter("codigo", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("p_notaCreditoEmitir", codigoParameter);
        }
    
        public virtual int p_prox(string codigo_anterior, ObjectParameter codigo_novo)
        {
            var codigo_anteriorParameter = codigo_anterior != null ?
                new ObjectParameter("codigo_anterior", codigo_anterior) :
                new ObjectParameter("codigo_anterior", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("p_prox", codigo_anteriorParameter, codigo_novo);
        }
    
        public virtual int p_proxFactura(ObjectParameter codigo_novo)
        {
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("p_proxFactura", codigo_novo);
        }
    
        public virtual int p_proxNotaCredito(ObjectParameter codigo_novo)
        {
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("p_proxNotaCredito", codigo_novo);
        }
    }
}
