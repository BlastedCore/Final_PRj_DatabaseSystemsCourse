using Interfaces.IModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Interfaces
{
    public interface IContext : IDisposable
    {
        IRepository<IChange_Log> Change_Log { get; }
        IRepository<IContribuinte> Contribuintes { get; }
        IRepository<IDevolucao> Devolucaos { get; }
        IRepository<IFactura> Facturas { get; }
        IRepository<IFactura_Contribuinte> Factura_Contribuinte { get; }
        IRepository<IItem> Items { get; }
        IRepository<INota_Credito> Nota_Credito { get; }
        IRepository<IProduto> Produtoes { get; }

        IQueryable<IListarNotasCredito> ListarNotasCredito(Nullable<int> ano);

        int CriaFactura(decimal? contribuinte, string nome, string morada, RetObj codigo);

        int CriaNotaCredito(string factura_codigo, RetObj codigo);

        int FacturaAnular(string codigo);

        int FacturaEmitir(string codigo);

        int FacturaProforma(string codigo);

        int NotaCreditoEmitir(string codigo);

        int SaveChanges();
    }
}
