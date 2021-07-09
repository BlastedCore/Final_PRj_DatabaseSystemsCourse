using Interfaces.IModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ADO.model
{
    public class Factura_Contribuinte : IFactura_Contribuinte
    {
        public string factura_codigo { get; set; }
        public decimal? contribuinte_id { get; set; }

        public virtual IContribuinte contribuinte { get; set; }

        public virtual IFactura factura { get; set; }
    }
}
