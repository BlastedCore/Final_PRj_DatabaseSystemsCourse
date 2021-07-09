using System;
using System.Collections.Generic;
using System.Text;

namespace Interfaces.IModel
{
    public interface IListarNotasCredito
    {
        string NotaCredito { get; set; }
        string Factura { get; set; }
        decimal Estado { get; set; }
        System.DateTime DataCriacao { get; set; }
        Nullable<System.DateTime> DataComplecao { get; set; }
        Nullable<decimal> Preco { get; set; }
        Nullable<decimal> IVA { get; set; }
    }
}
