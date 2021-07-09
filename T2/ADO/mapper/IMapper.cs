using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ADO.mapper
{
    public interface IMapper<TEntity>
    {
        int Insert(TEntity entity);
        TEntity Create();
        TEntity Read(params object[] keyValues);
        ICollection<TEntity> ReadAll();
        int Update(TEntity entity);
        int Delete(TEntity entity);
    }
}
