using Interfaces.IModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ADO.model
{
    public class Factura : IFactura
    {
        public string codigo { get; set; }
        public decimal estado { get; set; }
        public DateTime data_criacao { get; set; }
        public DateTime? data_complecao { get; set; }
        public decimal? preco { get; set; }
        public decimal? iva { get; set; }

        public virtual ICollection<IChange_Log> change_log { get; set; }

        public virtual IFactura_Contribuinte factura_contribuinte { get; set; }

        public virtual ICollection<IItem> items { get; set; }

        public virtual ICollection<INota_Credito> nota_credito { get; set; }
    }
}
