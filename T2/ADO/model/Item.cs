using Interfaces.IModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ADO.model
{
    public class Item : IItem
    {
        public decimal numero { get; set; }
        public decimal quantidade { get; set; }
        public decimal desconto { get; set; }
        public string descricao { get; set; }
        public int? produto_sku { get; set; }
        public string factura_codigo { get; set; }

        public virtual ICollection<IDevolucao> devolucaos { get; set; }

        public virtual IFactura factura { get; set; }
        public virtual IProduto produto { get; set; }
    }
}
