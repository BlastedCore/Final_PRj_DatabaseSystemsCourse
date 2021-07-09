using Interfaces.IModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EFModel
{
    public partial class factura_contribuinte : IFactura_Contribuinte
    {
        IContribuinte IFactura_Contribuinte.contribuinte { get => contribuinte; }
        IFactura IFactura_Contribuinte.factura { get => factura; }
    }
}
