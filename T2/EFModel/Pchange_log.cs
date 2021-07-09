using Interfaces.IModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EFModel
{
    public partial class change_log : IChange_Log
    {
        IFactura IChange_Log.factura { 
            get => factura; set => factura = (factura)value; 
        }
    }
}
