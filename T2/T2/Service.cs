using Interfaces;
using Interfaces.IModel;
using System;
using System.Collections.Generic;
using System.Data.Entity.Infrastructure;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Transactions;

namespace T2
{
    /**
     * This class should return wether the action was sucesifill and use out parameters for data
     * but...
     **/
    class Service
    {
        private Builder builder;

        public Service(Builder builder)
        {
            this.builder = builder;
        }
        internal string CreateInvoice()
        {
            RetObj ret = new RetObj();
            using (IContext ctx = builder.GetContext()) {
                ctx.CriaFactura(null,null,null,ret);
            }
            return (string)ret.value;
        }

        internal int AddItem(string code, int SKU, int quantity)
        {
            //grab the last used number and insert the new item with the next number
            TransactionOptions opt = new TransactionOptions();
            opt.IsolationLevel = IsolationLevel.Serializable;
            using (TransactionScope tran = new TransactionScope(TransactionScopeOption.Required, opt))
            {
                using (IContext ctx = builder.GetContext())
                {
                    IRepository<IItem> itemRep = ctx.Items;
                    IRepository<IFactura> facturaRep = ctx.Facturas;
                    IFactura factura = facturaRep.Find(code);
                    var facturaItems = factura.items;
                    int max = 0;
                    foreach (IItem i in facturaItems)
                    {
                        if (i.numero > max) max = (int)i.numero;
                    }
                    IItem item = itemRep.Create();
                    item.factura_codigo = code;
                    item.produto_sku = SKU;
                    item.quantidade = quantity;
                    item.numero = max + 1;
                    itemRep.Add(item);
                    //if there was concurrent interaction save changes will fail
                    try
                    {
                        int ret = ctx.SaveChanges();
                        tran.Complete();
                        return ret;
                    }
                    catch (DbUpdateException) { return 0; }
                }
            }
        }

        internal decimal ProformaInvoice(string code)
        {
            using (IContext ctx = builder.GetContext())
            {
                ctx.FacturaProforma(code);
                var facturasRep = ctx.Facturas;
                var factura = facturasRep.Find(code);

                return (decimal)(factura.preco + factura.iva);
            }
        }

        internal int EmitInvoice(string code)
        {
            int ret;
            using (IContext ctx = builder.GetContext())
            {
                ret = ctx.FacturaEmitir(code);
            }
            return ret;
        }

        internal string CreateCreditNote(string code)
        {
            RetObj ret = new RetObj();
            using (IContext ctx = builder.GetContext())
            {
                ctx.CriaNotaCredito(code, ret);
            }
            return (string)ret.value;
        }

        internal void ListYearCreditNotes(int i)
        {
            using (IContext ctx = builder.GetContext())
            {
                var notasCredito = ctx.ListarNotasCredito(i);
                var list = notasCredito.ToList();

                foreach (IListarNotasCredito entry in list) {
                    Console.WriteLine(entry.NotaCredito + " " + entry.Factura + " " + entry.Estado + " " + entry.DataCriacao + " " + entry.DataComplecao + " " + entry.Preco + " " + entry.IVA);
                }
            }
            
        }

        internal string GetNextInvoiceCode()
        {
            using (IContext ctx = builder.GetContext()) 
            {
                var facturaRep = ctx.Facturas;
                var list = facturaRep.ListAll();
                string lastCode = "";

                foreach(IFactura factura in list)
                {
                    if (lastCode.CompareTo(factura.codigo) < 0) lastCode = factura.codigo;
                }
                int year = DateTime.Now.Year;
                string[] parts = lastCode.Split('-');
                if (year != Int32.Parse(parts[0].Substring(2))){
                    return year + '-' + "00000";
                }
                return parts[0] + '-' + (Int32.Parse(parts[1]) + 1).ToString("D5");
            }
        }

        internal int SwapTaxpayer(string code1, string code2)
        {
            TransactionOptions opt = new TransactionOptions();
            opt.IsolationLevel = System.Transactions.IsolationLevel.RepeatableRead;
            using (TransactionScope tran = new TransactionScope(TransactionScopeOption.Required, opt))
            {
                using (IContext ctx = builder.GetContext()) 
                {
                    var facturaRep = ctx.Factura_Contribuinte;
                    var factura1 = facturaRep.Find(code1);
                    var factura2 = facturaRep.Find(code2);
                    if (factura1 == null || factura2 == null) return 0;
                    decimal temp = (decimal)factura1.contribuinte_id;
                    factura1.contribuinte_id = factura2.contribuinte_id;
                    factura2.contribuinte_id = temp;
                    //if save changes fails it means that there was concurrent interaction
                    try
                    {
                        int ret = ctx.SaveChanges();
                        tran.Complete();
                        return ret;
                    }
                    catch (DbUpdateException) { return 0; }
                }
            }
        }
    }
}
