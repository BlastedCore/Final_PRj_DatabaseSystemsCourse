using Interfaces;
using Interfaces.IModel;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.Objects;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EFModel
{
    public partial class L5DG_30_connection : IContext
    {

        public L5DG_30_connection(string connectionString) : base(connectionString)
        {
        }

        public IRepository<IChange_Log> Change_Log { 
            get => new EFRepository<IChange_Log, change_log>(change_log);
        }
        public IRepository<IContribuinte> Contribuintes 
        {
            get => new EFRepository<IContribuinte, contribuinte>(contribuintes);
        }
        public IRepository<IDevolucao> Devolucaos 
        {
            get => new EFRepository<IDevolucao, devolucao>(devolucaos);
        }
        public IRepository<IFactura> Facturas 
        {
            get => new EFRepository<IFactura, factura>(facturas);
        }
        public IRepository<IFactura_Contribuinte> Factura_Contribuinte 
        {
            get => new EFRepository<IFactura_Contribuinte, factura_contribuinte>(factura_contribuinte);
        }
        public IRepository<IItem> Items 
        {
            get => new EFRepository<IItem, item>(items);
        }
        public IRepository<INota_Credito> Nota_Credito 
        {
            get => new EFRepository<INota_Credito, nota_credito>(nota_credito);
        }
        public IRepository<IProduto> Produtoes 
        {
            get => new EFRepository<IProduto, produto>(produtoes);
        }

        public int CriaFactura(decimal? contribuinte, string nome, string morada, RetObj codigo)
        {
            ObjectParameter param = new ObjectParameter("codigo", typeof(string));
            int ret = p_criaFactura(contribuinte, nome, morada, param);
            codigo.value = param.Value;
            return ret;
        }

        public int CriaNotaCredito(string factura_codigo, RetObj codigo)
        {
            ObjectParameter param = new ObjectParameter("codigo", typeof(string));
            int ret = p_criaNotaCredito(factura_codigo, param);
            codigo.value = param.Value;
            return ret;
        }

        public int FacturaAnular(string codigo)
        {
            return p_facturaAnular(codigo);
        }

        public int FacturaEmitir(string codigo)
        {
            return p_facturaEmitir(codigo);
        }

        public int FacturaProforma(string codigo)
        {
            return p_facturaProforma(codigo);
        }

        public IQueryable<IListarNotasCredito> ListarNotasCredito(int? ano)
        {
            return f_listarNotasCredito(ano);
        }

        public int NotaCreditoEmitir(string codigo)
        {
            return p_notaCreditoEmitir(codigo);
        }
    }
}
