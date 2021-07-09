using ADO.Concrete;
using ADO.model;
using Interfaces.IModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ADO.mapper
{
    public class Factura_ContribuinteProxy : Factura_Contribuinte
    {
        ADOContext ctx;
        public Factura_ContribuinteProxy(ADOContext context)
        {
            ctx = context;
        }
        public override IContribuinte contribuinte { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }

        public override IFactura factura { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
    }
}
