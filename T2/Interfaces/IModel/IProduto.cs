using System;
using System.Collections.Generic;
using System.Text;

namespace Interfaces.IModel
{
    public interface IProduto
    {
        int sku { get; set; }
        decimal preco { get; set; }
        decimal iva { get; set; }
        string descricao { get; set; }

        ICollection<IItem> items { get; }
    }
}
