//------------------------------------------------------------------------------
// <auto-generated>
//    This code was generated from a template.
//
//    Manual changes to this file may cause unexpected behavior in your application.
//    Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace EFModel
{
    using System;
    using System.Collections.Generic;
    
    public partial class change_log
    {
        public int id { get; set; }
        public System.DateTime data_evento { get; set; }
        public string evento { get; set; }
        public decimal estado { get; set; }
        public string ip { get; set; }
        public string utilizador { get; set; }
        public string factura_codigo { get; set; }
    
        public virtual factura factura { get; set; }
    }
}
