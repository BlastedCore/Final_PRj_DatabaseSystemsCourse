using System;
using System.Configuration;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using CredentialManagement;
using System.Security;
using System.Transactions;
using System.Diagnostics;

namespace T2
{
    /**
     * Don't look at this class. It sucks
     * It is just a basic UI
     * it uses the Windows credential manager for authentification
     * You will find that if the app can authentificate succesefully it will never again ask the user/password
     * This UI is also missing a lot of usability features
     **/
    class Program
    {
        private static readonly String cred_target = "SI2_T2";
        private static Credential cred = new Credential { Target = cred_target };
        static void Main(string[] args)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["conStr"].ConnectionString;
            
            Boolean success = false;
            do
            {
                //no credentials found, create
                if (!cred.Load())
                {
                    Console.Write("Username: ");
                    cred.Username = Console.ReadLine();
                    Console.Write("Password: ");
                    cred.Password = Console.ReadLine();
                    cred.PersistanceType = PersistanceType.LocalComputer;

                    cred.Save();
                }
                //test credentials
                try
                {
                    SecureString pass = new SecureString();
                    foreach (char c in cred.Password)
                    {
                        pass.AppendChar(c);
                    }
                    pass.MakeReadOnly();
                    SqlCredential sqlCred = new SqlCredential(cred.Username, pass);

                    using (SqlConnection con = new SqlConnection(connectionString, sqlCred))
                    {
                        con.Open();
                        con.Close();
                        //credentials accepted
                        success = true;
                    }
                }
                catch (SqlException)
                {
                    cred.Delete();
                    Console.WriteLine("Unable to authentificate");
                }
            } while (!success);

            Console.WriteLine("Connection established");
            SelectAccessType();
            Console.WriteLine("Exiting aplication");
            Console.ReadKey();
        }

        static void SelectAccessType()
        {
            while (true)
            {
                Console.WriteLine("Select Access Type to the DB");
                Console.WriteLine("0 - Exit");
                Console.WriteLine("1 - EF");
                Console.WriteLine("2 - ADO");
                Console.WriteLine("3 - Test performance ADO vs EF");
                char k = Console.ReadKey().KeyChar;
                Console.WriteLine();
                int i;
                if (Int32.TryParse(k.ToString(), out i))
                {
                    switch (i)
                    {
                        case 0:
                            return;
                        case 1:
                            Menu(new Service(new Builder(Builder.AccessType.EF, cred)));
                            break;
                        case 2:
                            Menu(new Service(new Builder(Builder.AccessType.ADO, cred)));
                            break;
                        case 3:
                            TestPerformance();
                            break;
                        default:
                            Console.WriteLine("Unrecognized option");
                            break;
                    }
                }
                else
                {
                    Console.WriteLine("Unrecognized option");
                }
            }
        }

        private static void TestPerformance()
        {
            var EF = new Service(new Builder(Builder.AccessType.EF, cred));
            TransactionOptions opt = new TransactionOptions();
            opt.IsolationLevel = IsolationLevel.Serializable;
            Stopwatch sw = new Stopwatch();
            sw.Start();
            using (TransactionScope tran = new TransactionScope(TransactionScopeOption.Required, opt))
            {
                string code = EF.CreateInvoice();
                EF.AddItem(code, 6, 6);
                EF.ProformaInvoice(code);
                EF.EmitInvoice(code);
            }
            sw.Stop();
            Console.WriteLine("EF time -> " + sw.ElapsedMilliseconds);
            var ADO = new Service(new Builder(Builder.AccessType.ADO, cred));
            sw.Reset();
            sw.Start();
            using (TransactionScope tran = new TransactionScope(TransactionScopeOption.Required, opt))
            {
                string code = ADO.CreateInvoice();
                ADO.AddItem(code, 6, 6);
                ADO.ProformaInvoice(code);
                ADO.EmitInvoice(code);
            }
            sw.Stop();
            Console.WriteLine("ADO time -> " + sw.ElapsedMilliseconds);
        }

        static void Menu(Service service)
        {
            Console.WriteLine("Access type accepted");
            while (true)
            {
                Console.WriteLine("Select option:");
                Console.WriteLine("0 - Back");
                Console.WriteLine("1 - Create new Invoice");
                Console.WriteLine("2 - Add Item to Invoice");
                Console.WriteLine("3 - Proforma of Invoice");
                Console.WriteLine("4 - Emit Invoice");
                Console.WriteLine("5 - Create new Credit Note");
                Console.WriteLine("6 - List all Credit Notes from a year");
                Console.WriteLine("7 - Get next Invoice code without PreparedStatement");
                Console.WriteLine("8 - Swap the taxpayerID between two Invoices");
                char k = Console.ReadKey().KeyChar;
                Console.WriteLine();
                int i;
                if (Int32.TryParse(k.ToString(), out i)) 
                {
                    string code;
                    string line;
                    int ret;
                    switch (i)
                    {
                        case 0:
                            return;
                        case 1:
                            Console.WriteLine(service.CreateInvoice());
                            break;
                        case 2:
                            Console.Write("Invoice Code: ");
                            code = Console.ReadLine();
                            Console.Write("Product SKU :");
                            string sSku = Console.ReadLine();
                            Console.Write("Quantity :");
                            string sQuantity = Console.ReadLine();
                            int quantity;
                            if (Int32.TryParse(sSku, out i) && Int32.TryParse(sQuantity, out quantity))
                            {
                                Console.WriteLine(service.AddItem(code, i, quantity) == 0?"Failed adding item":"Item added");
                            }
                            else { Console.WriteLine("Invalid parameters"); }
                            break;
                        case 3:
                            Console.Write("Invoice Code: ");
                            code = Console.ReadLine();
                            decimal price = service.ProformaInvoice(code);
                            Console.WriteLine("Price = " + price);
                            break;
                        case 4:
                            Console.Write("Invoice Code: ");
                            code = Console.ReadLine();
                            Console.WriteLine(service.EmitInvoice(code) == 0 ? "Failed to emit" : "Invoice emited");
                            break;
                        case 5:
                            Console.Write("Invoice Code: ");
                            code = Console.ReadLine();
                            Console.WriteLine(service.CreateCreditNote(code));
                            break;
                        case 6:
                            Console.Write("Year: ");
                            line = Console.ReadLine();
                            if (Int32.TryParse(line.ToString(), out i)) {
                                service.ListYearCreditNotes(i);
                            }
                            else { Console.WriteLine("Invalid year"); }
                            break;
                        case 7:
                            Console.WriteLine(service.GetNextInvoiceCode());
                            break;
                        case 8:
                            Console.Write("First Code: ");
                            code = Console.ReadLine();
                            Console.Write("Second Code: ");
                            line = Console.ReadLine();
                            Console.WriteLine(service.SwapTaxpayer(code, line) == 0? "Failed to swap taxpayer": "Taxpayers swaped");
                            break;
                        default:
                            Console.WriteLine("Unrecognized option");
                            break;
                    }
                }
                else
                {
                    Console.WriteLine("Unrecognized option");
                }
            }
        }
    }
}
