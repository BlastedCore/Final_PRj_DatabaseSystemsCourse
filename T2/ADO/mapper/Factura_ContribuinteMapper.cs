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
    class Factura_ContribuinteMapper<TEntity> : IMapper<TEntity> where TEntity : IFactura_Contribuinte
    {
        ADOContext ctx;
        public Factura_ContribuinteMapper(ADOContext context)
        {
            ctx = context;
        }

        public TEntity Create()
        {
            IFactura_Contribuinte factura_Contribuinte = new Factura_ContribuinteProxy(ctx);
            return (TEntity)factura_Contribuinte;
        }

        public int Delete(TEntity entity)
        {
            IFactura_Contribuinte factura_Contribuinte = entity;
            SqlCommand cmd = ctx.CreateCommand();
            cmd.CommandText = "DELETE FROM dbo.factura_contribuinte WHERE factura_codigo = @codigo ";

            cmd.Parameters.AddWithValue("@codigo", factura_Contribuinte.factura_codigo);

            try
            {
                return cmd.ExecuteNonQuery();
            }
            catch (SqlException) { return 0; }

        }

        public int Insert(TEntity entity)
        {
            IFactura_Contribuinte factura_Contribuinte = entity;
            SqlCommand cmd = ctx.CreateCommand();
            cmd.CommandText = "INSERT INTO dbo.factura_contribuinte(factura_codigo,contribuinte_id) VALUES ( @codigo, @id )";

            cmd.Parameters.AddWithValue("@codigo", factura_Contribuinte.factura_codigo);
            cmd.Parameters.AddWithValue("@id", factura_Contribuinte.contribuinte_id);

            try
            {
                return cmd.ExecuteNonQuery();
            }
            catch (SqlException) { return 0; }
        }

        public TEntity Read(params object[] keyValues)
        {
            SqlCommand cmd = ctx.CreateCommand();
            string factura_codigo = null;
            decimal? id = null;

            if (keyValues[0] is string) factura_codigo = (string)keyValues[0];
            else id = (decimal?)keyValues[0];

            string text = "SELECT factura_codigo, contribuinte_id FROM dbo.factura_contribuinte WHERE " + (factura_codigo != null ? "factura_codigo = @p " : "contribuinte_id = @p ");

            cmd.CommandText = text;

            cmd.Parameters.AddWithValue("@p", keyValues[0]);

            try
            {
                var reader = cmd.ExecuteReader();
                reader.Read();
                var entity = Create();
                entity.factura_codigo = reader.GetString(0);
                entity.contribuinte_id = reader.GetDecimal(1);
                ((Repository<IFactura_Contribuinte>)ctx.Factura_Contribuinte).Attach(entity);
                return entity;
            }
            catch (SqlException) { return Create(); }
        }

        public ICollection<TEntity> ReadAll()
        {
            throw new NotImplementedException();
        }

        public int Update(TEntity entity)
        {
            IFactura_Contribuinte factura_Contribuinte = entity;
            SqlCommand cmd = ctx.CreateCommand();
            cmd.CommandText = "UPDATE dbo.factura_contribuinte SET contribuinte_id = @id WHERE factura_codigo = @codigo ";

            cmd.Parameters.AddWithValue("@id", factura_Contribuinte.contribuinte_id);
            cmd.Parameters.AddWithValue("@codigo", factura_Contribuinte.factura_codigo);

            try
            {
                return cmd.ExecuteNonQuery();
            }
            catch (SqlException) { return 0; }
        }
    }
}
