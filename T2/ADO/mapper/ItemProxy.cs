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
    public class ItemProxy : Item
    {
        ADOContext ctx;
        public ItemProxy(ADOContext context)
        {
            ctx = context;
        }

        public override ICollection<IDevolucao> devolucaos { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }

        public override IFactura factura { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
        public override IProduto produto { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
    }
}
