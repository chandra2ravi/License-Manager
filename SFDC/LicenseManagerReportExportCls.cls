public with sharing class LicenseManagerReportExportCls {
    public list<License_Key_User__c> lstLicenseKeyUsers{get;set;}
    transient public list<ReportWrap> lstReport{get;set;}
    public LicenseManagerReportExportCls(){
        lstLicenseKeyUsers = new list<License_Key_User__c>();
        Date fromDate;
        Date toDate;
        string strAccId;
        lstReport = new list<ReportWrap>();
        map<string,string> mapParams = new map<string,string>();
        if(apexpages.currentPage().getParameters()!=null){
            mapParams = apexpages.currentPage().getParameters();
            system.debug('mapParams==>'+mapParams);
            strAccId = mapParams.get('AccId');
            set<string> setContractIds = new set<string>();
            if(strAccId!=null && strAccId!='' && strAccId!='null'){
                for(License_Key_User__c LKU:[select id,name,Account__c,Account__r.Name,Email__c,Phone__c,Existing_license_Keys__c,License_Key__c,Product__c,Quantity__c,Generated_By__c, Total_Available_Qty__c, Total_Contract_Qty__c,
                Repository_host_instance__c,Version__c,Contact__c,Contact__r.Name,Transaction_Exception__c,License_Type__c,Generated_Date__c from License_Key_User__c where Created_Date__c>=:Date.valueOf(mapParams.get('From')) and Created_Date__c<=:Date.valueOf(mapParams.get('To')) and Account__c=:strAccId]){
                    if(LKU.Product__c!=null)
                        setContractIds.add(LKU.Product__c);
                    ReportWrap objwrap = new ReportWrap();
                    objwrap.obj = LKU;
                    lstReport.add(objWrap);
                }
            }else{
                for(License_Key_User__c LKU:[select id,name,Account__c,Account__r.Name,Email__c,Phone__c,Existing_license_Keys__c,License_Key__c,Product__c,Quantity__c,Generated_By__c, Total_Available_Qty__c, Total_Contract_Qty__c,
                Repository_host_instance__c,Version__c,Contact__c,Contact__r.Name,Transaction_Exception__c,License_Type__c,Generated_Date__c from License_Key_User__c where Created_Date__c>=:Date.valueOf(mapParams.get('From')) and Created_Date__c<=:Date.valueOf(mapParams.get('To'))]){
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
            mapproducts = new map<string,string>();
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