using System;
using System.Collections.Generic;
using System.Text;

namespace Interfaces.IModel
{
    public interface IFactura
    {
        string codigo { get; set; }
        decimal estado { get; set; }
        System.DateTime data_criacao { get; set; }
        Nullable<System.DateTime> data_complecao { get; set; }
        Nullable<decimal> preco { get; set; }
        Nullable<decimal> iva { get; set; }

        ICollection<IChange_Log> change_log { get; }
        
        IFactura_Contribuinte factura_contribuinte { get; set; }
        ICollection<IItem> items { get; }
        ICollection<INota_Credito> nota_credito { get; }
    }
}
