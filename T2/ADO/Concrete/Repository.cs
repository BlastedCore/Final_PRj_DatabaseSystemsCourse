using ADO.mapper;
using Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ADO.Concrete
{
    /**
     * This class should call the TEntity respective mapper to perform these actions
     * In addition this class should keep consistency between the added and removed entities
     * so that when SaveChanges() is called in the context the exact order is requested from 
     * the mappers
     * 
     * Corners where cut.
     * **/
    public class Repository<TEntity> : IRepository<TEntity>
    {
        ADOContext ctx;
        IMapper<TEntity> mapper;
        List<TEntity> watchList = new List<TEntity>();
        public Repository(ADOContext context, IMapper<TEntity> mapper) 
        {
            ctx = context;
            this.mapper = mapper;
        }
        //adds the item to the watch list
        public void Attach(TEntity entity) {
            watchList.Add(entity);
        }

        //updates the database with all modified entities
        public int SaveChanges() 
        {
            int i = 0;
            //should not be like this
            foreach (TEntity entity in watchList) 
            {
                i += mapper.Update(entity);
            }
            return i;
        }

        //does an insert
        public TEntity Add(TEntity entity)
        {
            mapper.Insert(entity);
            return entity;
        }
        //Creates a new instance of TEntity
        public TEntity Create()
        {
            return mapper.Create();
        }
        //does a select where key = params
        //has to save a separate copy of the item for when 
        public TEntity Find(params object[] keyValues)
        {
            return mapper.Read(keyValues);
        }

        //Does a select all
        public ICollection<TEntity> ListAll()
        {
            return mapper.ReadAll();
        }
        //Does a delete
        public TEntity Remove(TEntity entity)
        {
            mapper.Delete(entity);
            watchList.Remove(entity);
            return entity;
        }
    }
}
