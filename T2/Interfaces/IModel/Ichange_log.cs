using System;
using System.Collections.Generic;
using System.Text;

namespace Interfaces.IModel
{
    public interface IChange_Log
    {
        int id { get; set; }
        System.DateTime data_evento { get; set; }
        string evento { get; set; }
        decimal estado { get; set; }
        string ip { get; set; }
        string utilizador { get; set; }
        string factura_codigo { get; set; }

        IFactura factura { get; set; }
    }
}
