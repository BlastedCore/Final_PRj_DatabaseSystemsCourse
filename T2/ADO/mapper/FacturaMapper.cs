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
    class FacturaMapper<TEntity> : IMapper<TEntity> where TEntity : IFactura
    {
        ADOContext ctx;
        public FacturaMapper(ADOContext context) 
        {
            ctx = context;
        }

        public TEntity Create()
        {
            IFactura factura = new FacturaProxy(ctx);
            return (TEntity)factura;
        }

        public int Delete(TEntity entity)
        {
            throw new NotImplementedException();
        }

        public int Insert(TEntity entity)
        {
            throw new NotImplementedException();
        }

        public TEntity Read(params object[] keyValues)
        {
            SqlCommand cmd = ctx.CreateCommand();

            cmd.CommandText = "SELECT codigo, estado, data_criacao, data_complecao, preco, iva FROM dbo.factura WHERE codigo = @codigo";

            cmd.Parameters.AddWithValue("@codigo", keyValues[0]);

            try
            {
                using (var reader = cmd.ExecuteReader())
                {
                    reader.Read();
                    var entity = Create();
                    entity.codigo = reader.GetString(0);
                    entity.estado = reader.GetDecimal(1);
                    entity.data_criacao = reader.GetDateTime(2);
                    if (reader.IsDBNull(3)) entity.data_complecao = (DateTime?)null;
                    else entity.data_complecao = reader.GetDateTime(3);
                    if (reader.IsDBNull(4)) entity.preco = (decimal?)null;
                    else entity.preco = reader.GetDecimal(4);
                    if (reader.IsDBNull(5)) entity.iva = (decimal?)null;
                    else entity.iva = reader.GetDecimal(5);

                    ((Repository<IFactura>)ctx.Facturas).Attach(entity);
                    return entity;
                }
            }
            catch (SqlException) { return Create(); }
        }

        public ICollection<TEntity> ReadAll()
        {
            SqlCommand cmd = ctx.CreateCommand();

            cmd.CommandText = "SELECT codigo, estado, data_criacao, data_complecao, preco, iva FROM dbo.factura";
            List<TEntity> list = new List<TEntity>();
            try
            {
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var entity = Create();
                        entity.codigo = reader.GetString(0);
                        entity.estado = reader.GetDecimal(1);
                        entity.data_criacao = reader.GetDateTime(2);
                        if (reader.IsDBNull(3)) entity.data_complecao = (DateTime?)null;
                        else entity.data_complecao = reader.GetDateTime(3);
                        if (reader.IsDBNull(4)) entity.preco = (decimal?)null;
                        else entity.preco = reader.GetDecimal(4);
                        if (reader.IsDBNull(5)) entity.iva = (decimal?)null;
                        else entity.iva = reader.GetDecimal(5);
                        list.Add(entity);
                        ((Repository<IFactura>)ctx.Facturas).Attach(entity);
                    }
                    return list;
                }
            }
            catch (SqlException) { return list; }
        }

        public int Update(TEntity entity)
        {
            IFactura factura = entity;
            SqlCommand cmd = ctx.CreateCommand();
            cmd.CommandText = "UPDATE dbo.factura SET estado = @estado, data_criacao = @data_criacao, data_complecao = @data_complecao, preco = @preco, iva = @iva ";

            cmd.Parameters.AddWithValue("@estado", factura.estado);
            cmd.Parameters.AddWithValue("@data_criacao", factura.data_criacao);
            if(factura.data_complecao != null) cmd.Parameters.AddWithValue("@data_complecao", factura.data_complecao);
            else cmd.Parameters.AddWithValue("@data_complecao", DBNull.Value);
            cmd.Parameters.AddWithValue("@preco", factura.preco);
            cmd.Parameters.AddWithValue("@iva", factura.iva);

            try
            {
                return cmd.ExecuteNonQuery();
            }
            catch (SqlException) { return 0; }
        }
    }
}
