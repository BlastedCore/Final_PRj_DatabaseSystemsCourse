using System;
using System.Collections.Generic;
using System.Text;

namespace Interfaces.IModel
{
    public interface INota_Credito
    {
        string codigo { get; set; }
        decimal estado { get; set; }
        System.DateTime data_criacao { get; set; }
        Nullable<System.DateTime> data_complecao { get; set; }
        string factura_codigo { get; set; }
        Nullable<decimal> preco { get; set; }
        Nullable<decimal> iva { get; set; }

        ICollection<IDevolucao> devolucaos { get; }
        IFactura factura { get; set; }
    }
}
