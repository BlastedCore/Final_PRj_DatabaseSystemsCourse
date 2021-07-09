using System;
using System.Collections.Generic;
using System.Text;

namespace Interfaces.IModel
{
    public interface IContribuinte
    {
        decimal id { get; set; }
        string nome { get; set; }
        string morada { get; set; }

        ICollection<IFactura_Contribuinte> factura_contribuinte { get; }
    }
}
