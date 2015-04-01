using System;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Xml.Linq;
using BBS.License;
using ClassLibrary1;
using System.Diagnostics;

using System.Diagnostics;
using System.Text;
using System.Security.Cryptography;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
// [System.Web.Script.Services.ScriptService]
public class Service : System.Web.Services.WebService
{


    [WebMethod]
    public string Generate(short ProductID, bool IsTrial, Expiration expiration, DateTime ExpirationDate
        , int DaysFromNow, bool IsEnterprise, string OnlyFor, Limits Limit1, int Limit1Days, Limits Limit2
        , short Limit2Days, string ProductVersion, ushort KeyID, out string Error)
    {
        BBSLic lic = new BBSLic();
        string text = null;
        try
        {
            lic.IsTrial = IsTrial;
            if (expiration == Expiration.Never)
            {
                lic.MakePermanent();
            }
            if (expiration == Expiration.EndOf)
            {
                lic.ExpirationDate = ExpirationDate;
            }
            if (expiration == Expiration.DaysFromNow)
            {
                text = "Days to expiration must be a number.";
                lic.DaysToExpiration = DaysFromNow;
            }
            if (IsEnterprise)
            {
                lic.MakeEnterprise();
            }
            else
            {
                lic.SetScopeHash(OnlyFor);
            }
            text = "The value specified for Limit 1 must be a number from 0 to " + ((int)BBSLic.Limit1Max);
            if (Limit1 == Limits.NotApplicable)
            {
                lic.Limit1 = BBSLic.NotApplicable;
            }
            if (Limit1 == Limits.Unlimited)
            {
                lic.Limit1 = BBSLic.Unlimited;
            }
            if (Limit1 == Limits.Number)
            {
                lic.Limit1 = Limit1Days;
            }
            text = "The value specified for Limit 2 must be a number from 0 to " + ((short)0x7fff);
            if (Limit2 == Limits.NotApplicable)
            {
                lic.Limit2 = BBSLic.NotApplicable;
            }
            if (Limit2 == Limits.Unlimited)
            {
                lic.Limit2 = BBSLic.Unlimited;
            }
            if (Limit2 == Limits.Number)
            {
                lic.Limit2 = Limit2Days;
            }
            text = "Product ID must be a number greater than 0 and less than 32768.";

            lic.ProductID = ProductID;
            text = "Version must have form N.N, where N <= 15.";
            Version version = new Version(ProductVersion);
            lic.ProductVersion = version;
            text = "Key ID must be a number";
            lic.KeyID = KeyID;
        }
        catch (Exception)
        {
            Error = text;
            return "";
        }
        string keyString = lic.GetKeyString(PW());
        Error = string.Format("The license key is\n{0}\nCopy to clipboard?", keyString);

        return keyString;
    }

    private static byte[] PW()
    {
       // Process currentProcess = Process.GetCurrentProcess();
       // return BBSLic.GetHash(currentProcess.MachineName + currentProcess.Id);
        Process currentProcess = Process.GetCurrentProcess();
        string data = currentProcess.MachineName + currentProcess.Id;
        SHA1 sha1 = new SHA1Managed();
        UnicodeEncoding ue = new UnicodeEncoding();
        return sha1.ComputeHash(ue.GetBytes(data));
    }

    private string ShowMsg(LicErr err, string key)
    {
        string text = "Invalid key.";
        switch (err)
        {
            case LicErr.NotBase64:
                text = "The key contains invalid (not base 64) characters.";
                break;

            case LicErr.UnsupportedKeyVersion:
                text = string.Format("This is a version {0} key, which is not supported by this software.", BBSLic.KeyStringVersion(key));
                break;

            case LicErr.InvalidLength:
                text = "The key contains the wrong number of non-dash ('-') characters.";
                break;

            case LicErr.ChecksumError:
                text = "The key's checksum is incorrect.";
                break;

            case LicErr.FutureKey:
                text = "This key was created on a future date.";
                break;
        }
        return text;
    }

    private string CountToString(int count)
    {
        if (count == BBSLic.NotApplicable)
        {
            return "Not Applicable";
        }
        if (count == BBSLic.Unlimited)
        {
            return "Unlimited";
        }
        return count.ToString();
    }

    [WebMethod]
    public void ViewKey(string Key, out int? ProductID, out Version ProductVersion, out string KeyOut
        , out string KeyVer, out string Creation, out string Count1, out string Count2
        , out int? DaysRemain, out DateTime? ExpDate, out string ScopeHash, out ushort KeyID
        , out string LicType, out string Error)
    {
        ProductID = null;
        ProductVersion = new Version();
        KeyOut = "";
        KeyVer = "";
        Creation = "";
        Count1 = "";
        Count2 = "";
        DaysRemain = 0;
        ExpDate = null;
        KeyID = 0;
        LicType = "";
        Error = "";
        ScopeHash = "";

        BBSLic lic = new BBSLic();
        LicErr oK = lic.LoadKeyString(Key);
        switch (oK)
        {
            case LicErr.FutureKey:
                Error = this.ShowMsg(oK, Key);
                oK = LicErr.OK;
                break;

            case LicErr.OK:
                KeyOut = Key;
                KeyVer = lic.KeyVersion.ToString();
                Creation = lic.CreationDate.ToShortDateString();
                Count1 = this.CountToString(lic.Limit1);
                Count2 = this.CountToString(lic.Limit2);
                if (lic.IsPermanent)
                {
                    DaysRemain = null;
                    ExpDate = null;
                }
                else
                {
                    DaysRemain = ((int)lic.DaysToExpiration);
                    ExpDate = lic.ExpirationDate;
                }
                if (lic.IsEnterprise)
                {
                    ScopeHash = "0 (enterprise license)";
                }
                else
                {
                    ScopeHash = lic.ScopeHash.ToString();
                }
                KeyID = lic.KeyID;
                ProductID = lic.ProductID;
                ProductVersion = lic.ProductVersion;
                if (lic.IsTrial)
                {
                    LicType = "Trial";
                }
                else
                {
                    LicType = "Production";
                }
                break;
        }
        Error = this.ShowMsg(oK, Key);
    }

}
public enum Expiration
{
    Never, EndOf, DaysFromNow
}

public enum Limits
{
    NotApplicable, Unlimited, Number
}

