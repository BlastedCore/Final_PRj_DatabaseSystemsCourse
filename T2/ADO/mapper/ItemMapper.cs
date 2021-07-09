using ADO.Concrete;
using Interfaces.IModel;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ADO.mapper
{
    class ItemMapper<TEntity> : IMapper<TEntity> where TEntity : IItem
    {
        ADOContext ctx;
        public ItemMapper(ADOContext context)
        {
            ctx = context;
        }

        public TEntity Create()
        {
            IItem item = new ItemProxy(ctx);
            return (TEntity)item;
        }

        public int Delete(TEntity entity)
        {
            throw new NotImplementedException();
        }

        public int Insert(TEntity entity)
        {
            IItem factura_Contribuinte = entity;
            SqlCommand cmd = ctx.CreateCommand();
            cmd.CommandText = "INSERT INTO dbo.item(numero, quantidade, desconto, descricao, produto_sku, factura_codigo) VALUES ( @numero, @quantidade, @desconto, @descricao, @produto_sku, @factura_codigo )";

            cmd.Parameters.AddWithValue("@numero", factura_Contribuinte.numero);
            cmd.Parameters.AddWithValue("@quantidade", factura_Contribuinte.quantidade);
            cmd.Parameters.AddWithValue("@desconto", factura_Contribuinte.desconto);
            if(factura_Contribuinte.descricao != null)cmd.Parameters.AddWithValue("@descricao", factura_Contribuinte.descricao);
            else cmd.Parameters.AddWithValue("@descricao", DBNull.Value);
            cmd.Parameters.AddWithValue("@produto_sku", factura_Contribuinte.produto_sku);
            cmd.Parameters.AddWithValue("@factura_codigo", factura_Contribuinte.factura_codigo);

            try
            {
                return cmd.ExecuteNonQuery();
            }
            catch (SqlException) { return 0; }
        }

        public TEntity Read(params object[] keyValues)
        {
            throw new NotImplementedException();
        }

        public ICollection<TEntity> ReadAll()
        {
            throw new NotImplementedException();
        }

        public int Update(TEntity entity)
        {
            return 1;
        }

        internal ICollection<IItem> ReadFacturaItems(string codigo)
        {
            SqlCommand cmd = ctx.CreateCommand();

            cmd.CommandText = "SELECT numero, quantidade, desconto, descricao, produto_sku, factura_codigo FROM dbo.item WHERE factura_codigo = @codigo ";

            cmd.Parameters.AddWithValue("@codigo", codigo);
            List<IItem> list = new List<IItem>();
            try
            {
                using (var reader = cmd.ExecuteReader()) 
                {
                    while (reader.Read())
                    {
                        var entity = Create();
                        entity.numero = reader.GetDecimal(0);
                        entity.quantidade = reader.GetDecimal(1);
                        entity.desconto = reader.GetDecimal(2);
                        entity.descricao = reader.GetString(3);
                        entity.produto_sku = reader.GetInt32(4);
                        entity.factura_codigo = reader.GetString(5);
                        list.Add(entity);
                        ((Repository<IItem>)ctx.Items).Attach(entity);
                    }
                    return list;
                }
            }
            catch (SqlException) { return list; }
        }
    }
}
