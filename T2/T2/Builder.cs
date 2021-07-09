using Interfaces;
using EFModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CredentialManagement;
using System.Configuration;
using System.Data.EntityClient;
using System.Data.Common;
using ADO.Concrete;

namespace T2
{
    class Builder
    {
        public enum AccessType
        {
            ADO = 0,
            EF = 1
        }

        private AccessType accessType;
        private string connectionString;
        public Builder(AccessType accessType, Credential cred)
        {
            this.accessType = accessType;
            if (accessType == AccessType.EF) 
            {
                var originalConnectionString = ConfigurationManager.ConnectionStrings["conEF"].ConnectionString;
                var entityBuilder = new EntityConnectionStringBuilder(originalConnectionString);
                var factory = DbProviderFactories.GetFactory(entityBuilder.Provider);
                var providerBuilder = factory.CreateConnectionStringBuilder();

                providerBuilder.ConnectionString = entityBuilder.ProviderConnectionString;

                providerBuilder.Add("User Id", cred.Username);
                providerBuilder.Add("Password", cred.Password);

                entityBuilder.ProviderConnectionString = providerBuilder.ToString();

                connectionString = entityBuilder.ToString();
            }
            else if (accessType == AccessType.ADO) 
            {
                var originalConnectionString = ConfigurationManager.ConnectionStrings["conStr"].ConnectionString;
                connectionString = originalConnectionString + "User Id=" + cred.Username + ";Password=" + cred.Password + ";";
                
            }
            else throw new InvalidOperationException("Selected unsupported AccessType");
        }

        public IContext GetContext()
        {
            if (accessType == AccessType.EF) return new L5DG_30_connection(connectionString);
            if (accessType == AccessType.ADO) return new ADOContext(connectionString);
            return null;
        }
    }
}
