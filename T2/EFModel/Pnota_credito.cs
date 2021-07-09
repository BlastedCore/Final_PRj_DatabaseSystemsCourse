using Interfaces.IModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EFModel
{
    public partial class nota_credito : INota_Credito
    {
        ICollection<IDevolucao> INota_Credito.devolucaos { get => devolucaos.Cast<IDevolucao>().ToList(); }
        IFactura INota_Credito.factura { get => factura; set => factura = (factura)value; }
    }
}
