using System;
using System.Collections.Generic;
using System.Text;

namespace Interfaces
{
    public interface IRepository<TEntity>
    {
        TEntity Add(TEntity entity);
        TEntity Create();
        TEntity Find(params object[] keyValues);
        TEntity Remove(TEntity entity);
        ICollection<TEntity> ListAll();
    }
}
