using Interfaces.IModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ADO.model
{
    class ListarNotasCredito : IListarNotasCredito
    {
        public ListarNotasCredito(string v1, string v2, decimal v3, DateTime dateTime1, DateTime? dateTime2, decimal? v4, decimal? v5)
        {
            NotaCredito = v1;
            Factura = v2;
            Estado = v3;
            DataCriacao = dateTime1;
            DataComplecao = dateTime2;
            Preco = v4;
            IVA = v5;
        }

        public string NotaCredito { get; set; }
        public string Factura { get; set; }
        public decimal Estado { get; set; }
        public DateTime DataCriacao { get; set; }
        public DateTime? DataComplecao { get; set; }
        public decimal? Preco { get; set; }
        public decimal? IVA { get; set; }
    }
}
