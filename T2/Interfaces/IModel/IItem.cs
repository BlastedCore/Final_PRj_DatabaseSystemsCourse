using System;
using System.Collections.Generic;
using System.Text;

namespace Interfaces.IModel
{
    public interface IItem
    {
        decimal numero { get; set; }
        decimal quantidade { get; set; }
        decimal desconto { get; set; }
        string descricao { get; set; }
        Nullable<int> produto_sku { get; set; }
        string factura_codigo { get; set; }

        ICollection<IDevolucao> devolucaos { get; }
        IFactura factura { get; set; }
        IProduto produto { get; set; }
    }
}
