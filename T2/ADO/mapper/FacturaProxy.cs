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
    public class FacturaProxy : Factura
    {
        ADOContext ctx;
        public FacturaProxy(ADOContext context) 
        {
            ctx = context;
        }

        public override ICollection<IChange_Log> change_log { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }

        public override IFactura_Contribuinte factura_contribuinte { 
            get 
            {
                if (base.factura_contribuinte == null) base.factura_contribuinte = new Factura_ContribuinteMapper<IFactura_Contribuinte>(ctx).Read(codigo);
                return base.factura_contribuinte;
            }
            set 
            {
                base.factura_contribuinte = value;
            } 
        }

        public override ICollection<IItem> items
        {
            get
            {
                if (base.items == null) base.items = new ItemMapper<IItem>(ctx).ReadFacturaItems(codigo);
                return base.items;
            }
            set
            {
                base.items = value;
            }
        }

        public override ICollection<INota_Credito> nota_credito { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
    }
}
