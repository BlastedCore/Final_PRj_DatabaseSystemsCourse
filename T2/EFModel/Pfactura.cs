using Interfaces.IModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EFModel
{
    public partial class factura : IFactura
    {
        ICollection<IChange_Log> IFactura.change_log { get => change_log.Cast<IChange_Log>().ToList(); }
        IFactura_Contribuinte IFactura.factura_contribuinte { get => factura_contribuinte; set => factura_contribuinte = (factura_contribuinte)value; }
        ICollection<IItem> IFactura.items { get => items.Cast<IItem>().ToList(); }
        ICollection<INota_Credito> IFactura.nota_credito { get => nota_credito.Cast<INota_Credito>().ToList(); }
    }
}
