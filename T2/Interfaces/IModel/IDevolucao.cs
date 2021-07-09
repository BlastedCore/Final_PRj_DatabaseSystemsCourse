using System;
using System.Collections.Generic;
using System.Text;

namespace Interfaces.IModel
{
    public interface IDevolucao
    {
        decimal quantidade { get; set; }
        decimal item_numero { get; set; }
        string factura_codigo { get; set; }
        string nota_credito_codigo { get; set; }

        IItem item { get; }
        INota_Credito nota_credito { get; }
    }
}
