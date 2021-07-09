using Interfaces;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EFModel
{
    public class EFRepository<TEntity, Entity> : IRepository<TEntity> where Entity : class, TEntity where TEntity : class
    {

        public DbSet<Entity> DbSet { get; set; }

        public EFRepository(DbSet<Entity> dbSet)
        {
            DbSet = dbSet;
        }

        public TEntity Add(TEntity entity)
        {
            return DbSet.Add((Entity)entity);
        }

        TEntity IRepository<TEntity>.Create()
        {
            return DbSet.Create<Entity>();
        }

        public TEntity Find(params object[] keyValues)
        {
            return DbSet.Find(keyValues);
        }

        public TEntity Remove(TEntity entity)
        {
            return DbSet.Remove((Entity)entity);
        }

        public ICollection<TEntity> ListAll()
        {
            return DbSet.ToList<TEntity>();
        }
    }
}
