using ADO.mapper;
using ADO.model;
using Interfaces;
using Interfaces.IModel;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.Linq;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ADO.Concrete
{
    //prepared statements are executed instantly, so it is advised to SaveChanges before using them
    public class ADOContext : IContext
    {
        private readonly SqlConnection con;

        //Create the IRepository that serve just as a repository of objects for the context
        //open connection
        public ADOContext(string connectionString) 
        {
            con = new SqlConnection(connectionString);
            con.Open();
            Facturas = new Repository<IFactura>(this, new FacturaMapper<IFactura>(this));
            Factura_Contribuinte = new Repository<IFactura_Contribuinte>(this, new Factura_ContribuinteMapper<IFactura_Contribuinte>(this));
            Items = new Repository<IItem>(this, new ItemMapper<IItem>(this));
        }

        public SqlCommand CreateCommand()
        {
            return con.CreateCommand();
        }

        public IRepository<IChange_Log> Change_Log {get => throw new NotImplementedException();}
        public IRepository<IContribuinte> Contribuintes { get => throw new NotImplementedException();}
        public IRepository<IDevolucao> Devolucaos { get => throw new NotImplementedException();}
        public IRepository<IFactura> Facturas { get; set;}
        public IRepository<IFactura_Contribuinte> Factura_Contribuinte { get; set;}
        public IRepository<IItem> Items { get; set; }
        public IRepository<INota_Credito> Nota_Credito { get => throw new NotImplementedException();}
        public IRepository<IProduto> Produtoes { get => throw new NotImplementedException();}
        public int CriaFactura(decimal? contribuinte, string nome, string morada, RetObj codigo)
        {
            using (SqlCommand cmd = con.CreateCommand())
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "cliente.p_criaFactura";

                if (contribuinte == null) cmd.Parameters.AddWithValue("@contribuinte", DBNull.Value);
                else cmd.Parameters.AddWithValue("@contribuinte", contribuinte);
                if (nome == null) cmd.Parameters.AddWithValue("@nome", DBNull.Value);
                else cmd.Parameters.AddWithValue("@nome", nome);
                if (morada == null) cmd.Parameters.AddWithValue("@morada", DBNull.Value);
                else cmd.Parameters.AddWithValue("@morada", morada);

                cmd.Parameters.Add("@codigo", SqlDbType.VarChar, 12);
                cmd.Parameters["@codigo"].Direction = ParameterDirection.Output;

                try
                {
                    int i = cmd.ExecuteNonQuery();
                    codigo.value = Convert.ToString(cmd.Parameters["@codigo"].Value);
                    return i;
                }
                catch (SqlException) { return 0; }
            }
        }

        public int CriaNotaCredito(string factura_codigo, RetObj codigo)
        {
            using (SqlCommand cmd = con.CreateCommand())
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "cliente.p_criaNotaCredito";

                cmd.Parameters.AddWithValue("@factura_codigo", factura_codigo);

                cmd.Parameters.Add("@codigo", SqlDbType.VarChar, 12);
                cmd.Parameters["@codigo"].Direction = ParameterDirection.Output;

                try
                {
                    int i = cmd.ExecuteNonQuery();
                    codigo.value = Convert.ToString(cmd.Parameters["@codigo"].Value);
                    return i;
                }
                catch (SqlException) { return 0; }
            }
        }


        public int FacturaAnular(string codigo)
        {
            using (SqlCommand cmd = con.CreateCommand())
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "cliente.p_facturaAnular";

                cmd.Parameters.AddWithValue("@codigo", codigo);
                try
                {
                    return cmd.ExecuteNonQuery();
                }
                catch (SqlException) { return 0; }
            }
        }

        public int FacturaEmitir(string codigo)
        {
            using (SqlCommand cmd = con.CreateCommand())
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "cliente.p_facturaEmitir";

                cmd.Parameters.AddWithValue("@codigo", codigo);
                try
                {
                    return cmd.ExecuteNonQuery();
                }
                catch (SqlException) { return 0; }
            }
        }

        public int FacturaProforma(string codigo)
        {
            using (SqlCommand cmd = con.CreateCommand())
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "cliente.p_facturaProforma";

                cmd.Parameters.AddWithValue("@codigo", codigo);
                try
                {
                    return cmd.ExecuteNonQuery();
                }
                catch (SqlException) { return 0; }
            }
        }

        public IQueryable<IListarNotasCredito> ListarNotasCredito(int? ano)
        {
            using (SqlCommand cmd = con.CreateCommand())
            {
                var resultCollection = new List<IListarNotasCredito>();
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = "SELECT * FROM cliente.f_listarNotasCredito( @ano )";

                cmd.Parameters.AddWithValue("@ano", ano);
                try
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            resultCollection.Add(new ListarNotasCredito(
                                reader.GetString(0),
                                reader.GetString(1),
                                reader.GetDecimal(2),
                                reader.GetDateTime(3),
                                reader.IsDBNull(4) ? (DateTime?)null : reader.GetDateTime(4),
                                reader.IsDBNull(5) ? (decimal?)null : reader.GetDecimal(5),
                                reader.IsDBNull(6) ? (decimal?)null : reader.GetDecimal(6)
                                )
                            );
                        }

                    }
                }
                catch (SqlException) {}
                return resultCollection.AsQueryable<IListarNotasCredito>();
            }
        }

        public int NotaCreditoEmitir(string codigo)
        {
            using (SqlCommand cmd = con.CreateCommand())
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "cliente.p_notaCreditoEmitir";

                cmd.Parameters.AddWithValue("@codigo", codigo);
                try
                {
                    return cmd.ExecuteNonQuery();
                }
                catch (SqlException) { return 0; }
            }
        }
        //Should transfer the changes in the context to DB
        //Empty the alteration queue and return the number of altered objects
        public int SaveChanges()
        {
            int i = ((Repository<IFactura>)Facturas).SaveChanges();
            i += ((Repository<IFactura_Contribuinte>)Factura_Contribuinte).SaveChanges();
            return i + ((Repository<IItem>)Items).SaveChanges();
        }
        //terminate connection
        public void Dispose()
        {
            con.Close();
        }
    }
}
