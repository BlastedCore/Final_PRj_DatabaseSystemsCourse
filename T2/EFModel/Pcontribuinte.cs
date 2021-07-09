using Interfaces.IModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EFModel
{
    public partial class contribuinte : IContribuinte
    {
        ICollection<IFactura_Contribuinte> IContribuinte.factura_contribuinte { 
            get => factura_contribuinte.Cast<IFactura_Contribuinte>().ToList(); 
        }
    }
}
