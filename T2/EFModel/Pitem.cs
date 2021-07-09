using Interfaces.IModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EFModel
{
    public partial class item : IItem
    {
        ICollection<IDevolucao> IItem.devolucaos { get => devolucaos.Cast<IDevolucao>().ToList(); }
        IFactura IItem.factura { get => factura; set => factura = (factura)value; }
        IProduto IItem.produto { get => produto; set => produto = (produto)value; }
    }
}
