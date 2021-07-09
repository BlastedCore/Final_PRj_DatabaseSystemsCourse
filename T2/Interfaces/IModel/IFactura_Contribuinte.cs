using System;
using System.Collections.Generic;
using System.Text;

namespace Interfaces.IModel
{
    public interface IFactura_Contribuinte
    {
        string factura_codigo { get; set; }
        Nullable<decimal> contribuinte_id { get; set; }

        IContribuinte contribuinte { get;  }
        IFactura factura { get; }
    }
}
