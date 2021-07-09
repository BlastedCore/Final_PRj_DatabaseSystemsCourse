using Interfaces.IModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EFModel
{
    public partial class devolucao : IDevolucao
    {
        IItem IDevolucao.item { get => item; }
        INota_Credito IDevolucao.nota_credito { get => nota_credito;  }
    }
}
