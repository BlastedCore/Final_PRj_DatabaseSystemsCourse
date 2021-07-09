using Interfaces.IModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EFModel
{
    public partial class produto : IProduto
    {
        ICollection<IItem> IProduto.items { get => items.Cast<IItem>().ToList();  }
    }
}
