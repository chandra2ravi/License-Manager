public with sharing class LicenseManagerReportCls {
    public License_Key_User__c ObjKeyUser{get;set;}
    public Contact objFrom{get;set;}
    public Contact objTo{get;set;}
    transient public list<License_Key_User__c> lstLicenseKeyUsers{get;set;}
    transient public list<ReportWrap> lstReport{get;set;}
    
    public LicenseManagerReportCls(ApexPages.StandardController controller){
        lstReport = new list<ReportWrap>();
        ObjKeyUser = new License_Key_User__c();
        objFrom = new Contact(); 
        objTo = new Contact();
        lstLicenseKeyUsers = new list<License_Key_User__c>();
    }
    public string strPageUrl{get;set;}
    public pagereference ExportReport(){
        strPageUrl = '';
        if(objFrom.BirthDate!=null && objTo.BirthDate!=null){
            string strFrom = string.valueOf(objFrom.BirthDate);
            string strTo = string.valueOf(objTo.BirthDate);
            strPageUrl = '/apex/LicenseManagerReportExport?From='+strFrom+'&To='+strTo+'&AccId='+ObjKeyUser.Account__c;
            Pagereference pg = new Pagereference('/apex/LicenseManagerReportExport?From='+strFrom+'&To='+strTo+'&AccId='+ObjKeyUser.Account__c); 
            pg.setRedirect(true);
            return pg;
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please select Start and End dates.'));
            return null;
        }
    }
    public void GenerateReport(){
        lstLicenseKeyUsers = new list<License_Key_User__c>();
        lstReport = new list<ReportWrap>();
        if(objFrom.BirthDate!=null && objTo.BirthDate!=null){
            set<string> setContractIds = new set<string>();
            if(ObjKeyUser.Account__c!=null){
                for(License_Key_User__c LKU:[select id,name,Account__c,Account__r.Name,Email__c,Phone__c,Existing_license_Keys__c,License_Key__c,Product__c,Quantity__c,Generated_By__c, Total_Available_Qty__c, Total_Contract_Qty__c,
                Repository_host_instance__c,Version__c,Contact__c,Contact__r.Name,Transaction_Exception__c,License_Type__c,Generated_Date__c from License_Key_User__c where Created_Date__c>=:objFrom.BirthDate and Created_Date__c<=:objTo.BirthDate and Account__c=:ObjKeyUser.Account__c order by CreatedDate]){
                    if(LKU.Product__c!=null)
                        setContractIds.add(LKU.Product__c);
                    ReportWrap objwrap = new ReportWrap();
                    objwrap.obj = LKU;
                    lstReport.add(objWrap);
                }
            }else{
                for(License_Key_User__c LKU:[select id,name,Account__c,Account__r.Name,Email__c,Phone__c,Existing_license_Keys__c,License_Key__c,Product__c,Quantity__c,Generated_By__c, Total_Available_Qty__c, Total_Contract_Qty__c,
                Repository_host_instance__c,Version__c,Contact__c,Contact__r.Name,Transaction_Exception__c,License_Type__c,Generated_Date__c from License_Key_User__c where Created_Date__c>=:objFrom.BirthDate and Created_Date__c<=:objTo.BirthDate order by CreatedDate]){
                    if(LKU.Product__c!=null)
                        setContractIds.add(LKU.Product__c);
                    ReportWrap objwrap = new ReportWrap();
                    objwrap.obj = LKU;
                    lstReport.add(objWrap);
                }
            }
            map<string,string> mapproducts = new map<string,string>();
            if(setContractIds!=null && setContractIds.size()>0){
                for(Contract objContr:[select id,Contract_Products__c from Contract where Id IN:setContractIds and Contract_Products__c!=null]){
                    mapproducts.put(objContr.Id,objContr.Contract_Products__c);
                }
            }
            for(ReportWrap objwrap:lstReport){
                if(objwrap.obj.Product__c!=null && mapproducts.get(objwrap.obj.Product__c)!=null){
                    objwrap.productName = mapproducts.get(objwrap.obj.Product__c);
                }
            }
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please select Start and End dates.'));
        }
    }
    public class ReportWrap{
        public License_Key_User__c obj{get;set;}
        public string productName{get;set;}
        public ReportWrap(){
            obj = new License_Key_User__c();
            productName = '';
        }
    }
}