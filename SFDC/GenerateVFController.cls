public without sharing class GenerateVFController {

    public String Version { get; set; }   
    public string enternumlic { get; set; }
    public string Aditionalavi { get; set; }
    public string Currentlylic { get; set; }
    public string Currentlymon { get; set; }
    public String numlicensekeys { get; set; }
    public String aviablekeys { get; set; }
    public String Totalkeys { get; set; }
    public String Existinglickey { get; set; }
    public String LicenseKey { get; set; }
    public String Repositorylickey { get; set; }
    public Boolean replaceradio { get; set; }
    Public Boolean generateradio { get; set; }
    public String none { get; set; }
    public String Productlist { get; set; }
    Public String name{get;set;}
    Public String email{get;set;}
    Public String phonenumber{get;set;}
    
    
    public string ProductName{get;set;}//To display the Selected product is Step-3 and Steo-4
    public string ProductVersion{get;set;}//To display the Selected product version is Step-3 and Steo-4
    
    public Boolean step1 { get; set; }
    public Boolean step3b { get; set; }
    public Boolean step3a { get; set; }
    public Boolean step2 { get; set; }
    public Boolean step4 { get; set; }
    
    public boolean isValidServer {get;set;}
    public boolean isValidKey {get;set;}
    
    public string keyType{get;set;}
    public string strAccId{get;set;}
    public string strContactId{get;set;}
    public map<string,integer> produtIdMap{get;set;}
    
    public License_Key_User__c objKeyUser{get;set;}
    
    
    public string strProductName{get;set;}
    
    public list<Selectoption> lstAvailableExistingKeys{get;set;}
    
    public string strSelExistingKeys{get;set;}
    
    public boolean is_ProductPage{get;set;}
    
    set<id> setContractIds = new set<id>();
    
    public generatevfcontroller(){
        strSelVersion = '';
        step1=true;
        step2=false;
        step3b=false;
        step3a=false;
        step4=false;
        produtIdMap = new map<string,integer>();
        createProductMap();
        isValidServer = false;
        isValidKey = false;
        is_ProductPage = false;
         
        objKeyUser = new License_Key_User__c();
        
        lstAvailableExistingKeys = new list<Selectoption>();
         
        for(User objUser:[select id,Contact.AccountId, ContactId from User where id=:userinfo.getUserId() and ContactId!=null and Contact.AccountId!=null]){
            strAccId = objUser.Contact.AccountId;
            strContactId = objUser.ContactId;
        }
        //PrepareProducts_Versions();
        if(apexpages.currentPage().getParameters().get('Product')!=null){
            strProductName = apexpages.currentPage().getParameters().get('Product');
            //for(Contract objcon:[select id,Contract_Products__c from Contract where AccountId=:strAccId and Contract_Products__c=:strProductName and (Custom_Contract_End_Date__c > today OR Contract_Status__c= 'PO Pending')])
            for(Contract objcon:[select id,Contract_Products__c from Contract where AccountId=:strAccId and Contract_Products__c=:strProductName and (Custom_Contract_End_Date__c > today and (Contract_Status__c= 'PO Pending' or Contract_Status__c= 'Current'))]){
                Productlist = objcon.Id;
                setContractIds.add(objcon.Id);
                is_ProductPage = true;
            }
            objKeyUser.Product__c = strProductName;
            system.debug('Productlist===>'+Productlist);
            PrepareProducts_Versions();
            FetchVersions();
            //step1=false;
            //step2=true;
        }
    }
    
    public void createProductMap(){
        produtIdMap.put('SQLsecure',1000);
        produtIdMap.put('SQL change manager',1100);
        produtIdMap.put('SQL diagnostic manager',1200);
        produtIdMap.put('SQLsafe', 1300);
        produtIdMap.put('SQL compliance manager', 1400);
        produtIdMap.put('SQLconfig', 1500);
        produtIdMap.put('SQLtool', 1600);
        produtIdMap.put('SQLschedule', 1700);
        produtIdMap.put('SQL mobile manager', 1800);
        produtIdMap.put('SQLscaler',1900);
        produtIdMap.put('SQLstats',2000);
        produtIdMap.put('DM for Exchange',2100);
        produtIdMap.put('SQLdefrag',2200);
        produtIdMap.put('SharePoint backup',2700);
        produtIdMap.put('SharePoint dm',3000);
        produtIdMap.put('SharePoint audit',3200);
        produtIdMap.put('SQL Elements',3500);
        produtIdMap.put('SQL BI',4000);
        produtIdMap.put('SQL Enterprise Job Manager',4100);
    }
    
    public PageReference nextstep1(){
        /*
        for(License_Key_User__c obj:[select id,Name,Account__c,Email__c,Phone__c from License_Key_User__c where Email__c=:email and Account__c=:strAccId]){
            objKeyUser = obj;
        }
        */
        
        if(strAccId!=null)
            objKeyUser.Account__c = strAccId;
            
        if(strContactId!=null)
            objKeyUser.Contact__c = strContactId;
            
        if(email!=null && email!='')
            objKeyUser.Email__c = email;
        
        if(phonenumber!=null && phonenumber!='')
            objKeyUser.Phone__c = phonenumber;
        
        if(name!=null && name!='')
            objKeyUser.Name = name;
        
        try{
            if(objKeyUser.Product__c!=null && mapProductNames!=null && mapProductNames.get(objKeyUser.Product__c)!=null){
                objKeyUser.Product_Name__c = mapProductNames.get(objKeyUser.Product__c);
            }
            upsert objKeyUser;
        }catch(Exception e){
            
        }
        step1=false;
        step2=true;
        return null;
    }
    
    map<string,list<selectoption>> mapProductVersions = new map<string,list<selectoption>>();
    public list<selectoption> lstListProducts{get;set;}
    public list<selectoption> lstListVesrions{get;set;}
    public string strSelVersion{get;set;}
    
    map<string,string> mapProductContracts = new map<string,string>();
    map<string,string> mapProductNames = new map<string,string>();
    
    public void PrepareProducts_Versions(){
        strSelVersion = '';
        mapProductContracts = new map<string,string>();
        lstListProducts = new list<selectoption>();
        lstListVesrions = new list<selectoption>();
        lstListProducts.add(new selectoption('','--None--'));
        for(Contract objcon:[select id,Contract_Products__c from Contract where AccountId=:strAccId and Contract_Products__c!=null and Custom_Contract_End_Date__c > today and Contract_Products__c=:strProductName]){
            mapProductContracts.put(objcon.Contract_Products__c,objCon.Id);
        }
        if(mapProductContracts!=null && mapProductContracts.size()>0){
            for(License_Manager__c objLicManager:[select id,Product_Name__c,Versions__c from License_Manager__c where Active__c=true and Product_Name__c IN:mapProductContracts.keyset()]){
                list<string> lstVer = new list<string>();
                list<selectoption> lstversions = new list<selectoption>();
                if(objLicManager.Versions__c!=null){
                    if(objLicManager.Versions__c.indexOf(';')>-1){
                        lstVer = objLicManager.Versions__c.split(';');
                    }else{
                        lstVer.add(objLicManager.Versions__c);
                    }
                    list<decimal> lstDecVersions = new list<decimal>();
                    
                    for(string strver:lstVer){
                        decimal decVer = decimal.valueOf(strver.trim());
                        lstDecVersions.add(decVer);
                    }
                    lstDecVersions.sort();
                    for(decimal vers:lstDecVersions){
                    	strSelVersion = vers+'';
                        lstversions.add(new selectoption(string.valueOf(vers),string.valueOf(vers)));
                    }
                }else{
                    lstversions.add(new selectoption('','--None--'));
                }
                if(mapProductContracts.get(objLicManager.Product_Name__c)!=null)
                    mapProductVersions.put(mapProductContracts.get(objLicManager.Product_Name__c),lstversions);
            }
        }
        if(mapProductContracts!=null && mapProductContracts.size()>0){
            for(string prod:mapProductContracts.keyset()){
                if(mapProductContracts.get(prod)!=null){
                    lstListProducts.add(new selectoption(mapProductContracts.get(prod),prod));
                    mapProductNames.put(mapProductContracts.get(prod),prod);    
                }
            }
        }
        system.debug('mapProductNames===>'+mapProductNames);
    }
    public void FetchVersions(){
        lstListVesrions = new list<selectoption>();
        lstAvailableExistingKeys = new list<Selectoption>();
        system.debug('Productlist===>'+Productlist);
        system.debug('mapProductNames===>'+mapProductNames);
        
        if(Productlist!=null && Productlist!='' && mapProductVersions.get(Productlist)!=null){
            lstListVesrions = mapProductVersions.get(Productlist);
        }
        if(Productlist!=null && Productlist!='' && strAccId!='' && strAccId!='' && mapProductNames.get(Productlist)!=null){
            system.debug('Product Name===>'+mapProductNames.get(Productlist));
            for(Asset objAsst:[SELECT Account.Name,Active_Key__c,Enterprise__c,Name,Contact.name,Expiration_Date__c,Instances__c,License_Keys__c,Product_Name__c,Quantity,Version__c, Scope__c FROM Asset WHERE Active_Key__c = true and AccountId =:strAccId and Product_Name__c=:mapProductNames.get(Productlist)]){
                lstAvailableExistingKeys.add(new selectoption(objAsst.License_Keys__c,objAsst.License_Keys__c));
            }
        }
    }
    public PageReference copytoclipboard() {
    
        return null;
    }
    
    public void GenerateLicenseKeyStep3b() {
    	/*
        list< Contract > contracts = [ select Id, Contract_Quantity__c, Contract_Products__c, EndDate from Contract where Id =: Productlist ];
        //date contractEndDate;
        if(contracts != null && contracts.size() > 0 && contracts[0].Contract_Quantity__c != null ){
            //Aviablekeys = string.valueOf ( contracts[0].Contract_Quantity__c );
            //enternumlic  = string.valueOf ( contracts[0].Contract_Quantity__c );
            ProductName = contracts[0].Contract_Products__c;
            contractEndDate = contracts[0].EndDate;
        }
        ProductVersion = strSelVersion;
        
        system.debug('enternumlic==>'+enternumlic);
        system.debug('aviablekeys==>'+aviablekeys);
        system.debug('ProductName==>'+ProductName);
        system.debug('ProductVersion==>'+ProductVersion);
        
        if (enternumlic != null && enternumlic != '' &&  integer.valueOf(enternumlic)>0 && integer.valueOf(enternumlic)<=integer.valueOf(aviablekeys) && integer.valueOf(enternumlic)<=500){
            //LicenseKey = generateKey( produtIdMap.get(ProductName), contractEndDate, strSelVersion );// Need webservice integration
            if ( Existinglickey != '')
            {
                objKeyUser.Quantity__c = integer.valueOf(enternumlic);
                list<Asset> assets = new list<Asset> ( );
                // need to split and send it to
                list<string> keys;
                if(Existinglickey!=null && Existinglickey!='')
                    keys = Existinglickey.split(';');
                if (keys != null && keys.size()>0){
                    LicenseKey = generateKey( produtIdMap.get(ProductName), contractEndDate, strSelVersion );//need only for and sepersate asset or seperate key
                    if (LicenseKey!=null && LicenseKey!=''){
                        createAsset(ProductName,contractEndDate,strSelVersion,true,LicenseKey,decimal.valueOf(enternumlic),Repositorylickey,assets);
                        insert assets;
                        
                        step4=true;
                        step3b=false;
                        objKeyUser.License_Key__c = LicenseKey;
                        if(objKeyUser.Product__c!=null && mapProductNames!=null && mapProductNames.get(objKeyUser.Product__c)!=null){
                            objKeyUser.Product_Name__c = mapProductNames.get(objKeyUser.Product__c);
                        }
                        try{
                            objKeyUser.Generated_Date__c = system.now();
                            upsert objKeyUser;
                        }catch(Exception e){
                            
                        }
                    }
                }
                //for ( string str : keys )
                //{
                //  generateKey( produtIdMap.get(ProductName), contractEndDate, strSelVersion );//need only for and sepersate asset or seperate key
                //}
            }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please contact licensing@idera.com.'));
        }
        */
    }

    public PageReference previousStep3b() {
        step3b=false;
        step2=true;
        return null;
    }
    
    public date contractEndDate{get;set;}
    public void GenerateLicenseKeystep3a() {
    	//system.debug('Productlist===>'+Productlist);
    	if(numlicensekeys==null || (numlicensekeys!=null && (numlicensekeys.isNumeric()==false || numlicensekeys == '' || (numlicensekeys.isNumeric() && integer.valueOf(numlicensekeys)< 0)))){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Enter the number of license to use value.'));
    		return ;
    	}
        list<Contract> contracts = [ select Id, Contract_Quantity__c, Contract_Products__c, EndDate from Contract where Id =: Productlist ];
        //date contractEndDate;
        if (contracts != null && contracts.size() > 0 && contracts[0].Contract_Quantity__c != null ){
            //Aviablekeys = string.valueOf ( contracts[0].Contract_Quantity__c );
            //numlicensekeys = string.valueOf ( contracts[0].Contract_Quantity__c );
            ProductName = contracts[0].Contract_Products__c;
            contractEndDate = contracts[0].EndDate;
        }
        ProductVersion = strSelVersion;
        system.debug('enternumlic==>'+enternumlic);
        system.debug('numlicensekeys==>'+numlicensekeys);
        system.debug('aviablekeys==>'+aviablekeys);
        system.debug('ProductName==>'+ProductName);
        system.debug('ProductVersion==>'+ProductVersion);
        
        if (numlicensekeys != null && numlicensekeys != '' && numlicensekeys.isNumeric() && integer.valueOf(numlicensekeys)>0 && integer.valueOf (aviablekeys)>=integer.valueOf(numlicensekeys) && integer.valueOf(numlicensekeys)<=500){
            objKeyUser.Quantity__c = integer.valueOf(numlicensekeys);
            LicenseKey = generateKey( produtIdMap.get(ProductName), contractEndDate, strSelVersion );// Need webservice integration
            if ( LicenseKey != '' )
            {
                list<Asset> assets = new list<Asset> ( );
                createAsset(ProductName, contractEndDate, strSelVersion, false, LicenseKey, decimal.valueOf ( numlicensekeys ), Repositorylickey, assets );
                insert assets;
                
                objKeyUser.License_Key__c = LicenseKey;
                if(objKeyUser.Product__c!=null && mapProductNames!=null && mapProductNames.get(objKeyUser.Product__c)!=null){
                    objKeyUser.Product_Name__c = mapProductNames.get(objKeyUser.Product__c);
                }
                try{
                    objKeyUser.Generated_Date__c = system.now();
                    objKeyUser.Generated_By__c = Userinfo.getUserId();
                    objKeyUser.Total_Available_Qty__c =integer.valueOf(Aviablekeys);
                    objKeyUser.Total_Contract_Qty__c = integer.valueOf(Totalkeys);
                    upsert objKeyUser;
                }catch(Exception e){
                    
                }
                step4=true;
                step3a=false;
            }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please contact licensing@idera.com.'));
        }
    }
    
    public string generateKey(integer ProductID, Date Expiration, string ProductVersion){
        try{
            LicenseManagerWS.LicenseMgrSoap license = new LicenseManagerWS.LicenseMgrSoap();//NotApplicable
            //integer ProductID = 1000;
            DateTime ExpirationDate = DateTime.newInstance(Expiration.year(), Expiration.month(), Expiration.day(), 23, 0, 0);
            boolean IsEnterprise = false;
            string OnlyFor;
            integer KeyID = 99;
            //Repositorylickey = 'enterprise';
            
            if ( Repositorylickey != null && Repositorylickey != '' && Repositorylickey.toLowerCase() == 'enterprise' )
                IsEnterprise = true;
            else
                OnlyFor = Repositorylickey;
            if(!Test.isRunningTest()){
            	system.debug('Product id==>'+ProductID);
		        system.debug('ExpirationDate==>'+ExpirationDate);
		        system.debug('IsEnterprise==>'+IsEnterprise);
        		system.debug('OnlyFor==>'+OnlyFor);
        		system.debug('ProductVersion==>'+ProductVersion);
        		
                LicenseManagerWS.GenerateResponse_element element = license.Generate(ProductID, false, 'Never', ExpirationDate, 0, IsEnterprise, OnlyFor,
                 'Number', integer.valueOf ( numlicensekeys ), 'Number', 1, ProductVersion, KeyID);
                //system.debug('test### '+element.GenerateResult);
                system.debug('element.GenerateResult===>'+element.GenerateResult);
                return element.GenerateResult;
            }else{
                return 'ASDFXVASGYLKJHF';
            }
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please contact licensing@idera.com.'));
            string strException = string.valueOf(ex.getMessage());
            if(strException!=null && strException!=''){
                if(strException.length()>255)
                    objKeyUser.Transaction_Exception__c = strException.subString(0,254);
                else
                    objKeyUser.Transaction_Exception__c = strException;
                    
                upsert objKeyUser;
            }
            Advanced_Log__c objAdvLog = new Advanced_Log__c();
            objAdvLog.Log_Message__c = 'ProductID '+ProductID +' Expiration '+Expiration+' ProductVersion '+ProductVersion +' Repositorylickey '+Repositorylickey;
            objAdvLog.Received_Data__c = ex.getMessage();
            objAdvLog.Process__c = 'Licensing';
            objAdvLog.User_ID__c = Userinfo.getUserId();
            objAdvLog.Status__c = 'New';
            objAdvLog.Log_Type__c = 'Error';
            insert objAdvLog;
            return '';
        }
    }
    public void createAsset(string ProductName, Date Expiration, string ProductVersion, boolean ReplacementKey, string LicenseKey, decimal Quantity, string Scope, list<Asset> assets ){
        system.debug('ProductName===>'+ProductName);
        system.debug('Scope===>'+Scope);
        system.debug('LicenseKey===>'+LicenseKey);
        string ProductId = '';
        string Product_FullName = ProductName+' - License';
        //'SQL Diagnostic Manager - License'
        for(Product2 prod:[select id from Product2 where Name=:Product_FullName limit 1]){
        	ProductId = prod.Id;
        }
        Asset assetLicense = new Asset( );
        assetLicense.Key_Type__c = 'New';
        assetLicense.Name = 'License Key';
        assetLicense.ProductName__c = ProductName;
        
        assetLicense.AccountId = strAccId;
        assetLicense.ContactId = strContactId;
        assetLicense.Active_Key__c = true;
        //assetLicense.Enterprise__c = true;
        //assetLicense.Expiration_Date__c = Expiration;
        assetLicense.Instances__c = Quantity;
        if(ProductId!=null && ProductId!='')
        	assetLicense.Product2Id = ProductId;
        assetLicense.License_Keys__c = LicenseKey;
        assetLicense.ReplacementKeyRequested__c = ReplacementKey;
        assetLicense.KeyReplaced__c = ReplacementKey;
        assetLicense.Scope__c = Scope;
        assetLicense.Version__c = ProductVersion;
        assetLicense.License_Key_User__c=Userinfo.getUserId();
        assetLicense.License_Generated__c=System.today();
        assets.add( assetLicense );
        //insert assetLicense;
    }
    public PageReference previousStep3a(){
        step3a=false;
        step2=true;
        return null;
    }
    public string strServerName{get;set;}
    public void nextStep2() {
        system.debug('Productlist===>'+Productlist);
        system.debug('strSelVersion===>'+strSelVersion);
        system.debug('keyType===>'+keyType);
        system.debug('Repositorylickey===>'+Repositorylickey);
        
        keyType = 'newkey';
        
        if(Productlist!=null && Productlist!='' && strSelVersion!=null && strSelVersion!=''){
            ProductVersion = strSelVersion;
            objKeyUser.Product__c = Productlist;
            objKeyUser.Version__c = strSelVersion;
            
            integer TotalKeysCount = 0;
            
            list<Contract> contracts = [select Id, Contract_Quantity__c, Contract_Products__c,EndDate from Contract where Id IN:setContractIds];
            integer AvailContractQuantity = 0;
            if(contracts != null && contracts.size() > 0){
            	// &&  contracts[0].Contract_Quantity__c != null
            	for(Contract objContr:contracts){
            		if(objContr.Contract_Quantity__c!=null)
            			TotalKeysCount = TotalKeysCount + integer.valueOf(objContr.Contract_Quantity__c); 
            	}
                ProductName = contracts[0].Contract_Products__c;
                contractEndDate = contracts[0].EndDate;
                Totalkeys  = string.valueOf (TotalKeysCount);
                AvailContractQuantity = TotalKeysCount;
                Currentlymon = string.valueOf (TotalKeysCount);
                if(TotalKeysCount!=null && TotalKeysCount>0)
                    Aviablekeys = string.valueOf(TotalKeysCount);
                else
                    Aviablekeys = string.valueOf(0);
            }
        	/*for ( Contract cont : [ select Id, Contract_Quantity__c from Contract where AccountId =:strAccId and Contract_Products__c =: ProductName ] )
        	{
        		Totalkeys  = string.valueOf ( cont.Contract_Quantity__c );
        	}*/
            if(contracts != null && contracts.size() > 0 && contracts[0].Contract_Quantity__c != null){
                /*
                if(contracts[0].Contract_Quantity__c!=null && contracts[0].Contract_Quantity__c>0)
                    Aviablekeys = string.valueOf ( contracts[0].Contract_Quantity__c );
                else
                    Aviablekeys = string.valueOf(0);
                AvailContractQuantity = integer.valueOf(contracts[0].Contract_Quantity__c);
                Currentlymon = string.valueOf ( contracts[0].Contract_Quantity__c );
				ProductName = contracts[0].Contract_Products__c;
				*/                
                
            }
            objKeyUser.Repository_host_instance__c = Repositorylickey;
            objKeyUser.Existing_license_Keys__c = Existinglickey;
            list<Asset> assets = [SELECT Account.Name,Active_Key__c,Enterprise__c, Name, Contact.name, Expiration_Date__c,  Instances__c, License_Keys__c, Product_Name__c, Quantity,
                                    Version__c, Scope__c
                                    FROM Asset
                                    WHERE Active_Key__c = true and AccountId =:strAccId and Product_Name__c=:ProductName and Version__c=:strSelVersion];
            system.debug('assets==>'+assets);      
            integer UsedLicenses = 0;
            for(Asset objAsset:[select id,Name,Instances__c,Product_Name__c from Asset where AccountId=:strAccId and Product_Name__c=:ProductName and Version__c=:strSelVersion and Active_Key__c=true and Instances__c!=null]){
                UsedLicenses = UsedLicenses + integer.valueOf(objAsset.Instances__c);
            }
            
            if(AvailContractQuantity - UsedLicenses>0)
                Aviablekeys = string.valueOf(AvailContractQuantity - UsedLicenses);
            else
                Aviablekeys = string.valueOf(0);
                
            if(keyType == 'newkey'){
                objKeyUser.License_Type__c = 'New Key';
                existinglickey='';
                isValidServer = false;
                for(Asset asst: assets){
                    system.debug('Repositorylickey==>'+Repositorylickey);
                    system.debug('asst.Scope__c==>'+asst.Scope__c);
                    if(asst.Scope__c != null && Repositorylickey == asst.Scope__c && ProductName == asst.Product_Name__c){
                        isValidServer = true;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Existing licenses available'));
                        break;
                    }
                }
                strServerName = Repositorylickey;
                system.debug('isValidServer==>'+isValidServer);
                if(Repositorylickey==null || (Repositorylickey!=null && Repositorylickey.trim()=='')){
                    isValidServer = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide Server or instance details.'));
                }
                if(!isValidServer){
                    step3a=true;
                    step2=false;
                }
            }
            /*
            else if(keyType == 'replacekey'){
                objKeyUser.License_Type__c = 'Replace Key';
                system.debug('existinglickey===>'+existinglickey);
                Repositorylickey='';
                if(existinglickey != null && existinglickey != ''){
                    list<string> existingKeys = new list<string>();
                    if(existinglickey.indexOf(';')>-1){
                        existingKeys = existinglickey.split(';');
                    }else{
                        existingKeys.add(existinglickey);
                    }
                    
                    integer TotalNumberofInstances = 0;
                    set<string> assetKeys = new set<string>();
                    for(Asset asst: assets){
                        if(asst.License_Keys__c != null){
                            assetKeys.add(asst.License_Keys__c.toLowerCase());
                        }
                        
                        boolean keyfound = false;
                        for(string Exiskey : existingKeys){
                            if(asst.License_Keys__c!=null && asst.License_Keys__c.indexOf(Exiskey)>-1){
                                keyfound = true;
                            }
                        }
                        if(keyfound && asst.Instances__c!=null){
                            TotalNumberofInstances = TotalNumberofInstances+integer.valueOf(asst.Instances__c);
                        }
                    }
                    
                    system.debug('TotalNumberofInstances===>'+TotalNumberofInstances);
                    Aviablekeys = string.valueOf(TotalNumberofInstances);
                    system.debug('Aviablekeys===>'+Aviablekeys);
                    
                    system.debug('assetKeys===>'+assetKeys);
                    system.debug('existingKeys===>'+existingKeys);
                    
                    integer invalidKeyCount = 0;
                    integer validKeyCount = 0;
                    string InvalidKeysMesg = '';
                    for(string key : existingKeys){
                        system.debug('key===>'+key);
                        if(!assetKeys.contains(key.toLowerCase())){
                            isValidKey = true;
                            if(InvalidKeysMesg!='')
                                InvalidKeysMesg = InvalidKeysMesg +',' +key;
                            else
                                InvalidKeysMesg = key;
                                
                            invalidKeyCount = invalidKeyCount+1;
                        }else{
                            validKeyCount = validKeyCount + 1;
                        }
                    }
                    if(validKeyCount==0){
                        isValidKey = true;
                    }else{
                        if(invalidKeyCount==0){
                            isValidKey = false;
                        }else{
                            isValidKey = true;
                        }
                    }
                    system.debug('isValidKey===>'+isValidKey);
                    if(!isValidKey){
                        set<string> setProdNames = new set<string>();
                        integer TotalOtherAvailLicences = 0;
                        for(Contract objContract:[select Id,Contract_Quantity__c,Contract_Products__c from Contract where Id !=:Productlist and AccountId=:strAccId and Contract_Quantity__c!=null and Custom_Contract_End_Date__c > today and Contract_Products__c!=null]){
                            setProdNames.add(objContract.Contract_Products__c);
                            TotalOtherAvailLicences = TotalOtherAvailLicences + integer.valueOf(objContract.Contract_Quantity__c);
                        }
                        integer UsedOtherLicenses = 0;
                        for(Asset objAsst:[select id,Instances__c from Asset where Name IN:setProdNames and AccountId=:strAccId and Instances__c!=null and Active_Key__c=true]){
                            UsedOtherLicenses = UsedOtherLicenses + integer.valueOf(objAsst.Instances__c);
                        }
                        Aditionalavi = string.valueOf(TotalOtherAvailLicences - UsedOtherLicenses);
                        step3b=true;
                        step2=false;
                    }else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The License key(s) you entered '+ InvalidKeysMesg +' are invalid, Please enter valid key information.'));
                    }
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide the existing License key(s) to proceed.'));
                }
            }
            */
            system.debug('step3a==>'+step3a);
            system.debug('step2==>'+step2);
            try{
                if(objKeyUser.Product__c!=null && mapProductNames!=null && mapProductNames.get(objKeyUser.Product__c)!=null){
                    objKeyUser.Product_Name__c = mapProductNames.get(objKeyUser.Product__c);
                }
                upsert objKeyUser;
            }catch(Exception e){
            
            }
        }else{
            if(Productlist==null || (Productlist!=null && Productlist==''))
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Product to proceed.'));
            if(strSelVersion==null || (strSelVersion!=null && strSelVersion==''))
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Version of the Product to proceed.'));
        }
    }
    
    public PageReference previousStep2(){
        step1=true;
        step2=false;
        return null;
    }

    public void sendviaemail(){
        // Create Email and Send
        string TemplateId = '';
    	for(EmailTemplate objEmailTemp:[select id from EmailTemplate where DeveloperName='New_License_Key_Generation' and IsActive=true]){
    		TemplateId = objEmailTemp.Id;
    	}
        if(email!=null && email!=null && TemplateId!=null && TemplateId!=''){
        	Contact objEmailCon = new Contact();
        	for(Contact con:[select id from Contact where Email='SendMail@idera.com']){
        		objEmailCon.Id = con.Id;
        	}
        	objEmailCon.LastName = 'Send Email contact';
        	objEmailCon.Lead_Source_Original__c = 'Web';
        	objEmailCon.Email = 'SendMail@idera.com';
        	try{
        		upsert objEmailCon;
        		
        		Messaging.SingleEmailMessage semResult = new Messaging.SingleEmailMessage();
	            semResult.setToAddresses(new String[] {email});
	        	semResult.setTemplateId(TemplateId);
	        	semResult.setWhatId(objKeyUser.Id);
	        	semResult.setTargetObjectId(objEmailCon.Id);
	        	semResult.setSaveAsActivity(false);
	        	/*
	            semResult.setSubject('License Key');
	            semResult.setPlainTextBody('License Key 333x-7777-jhh5-jhgg-ggg7 for ' + ProductName +' version '+strSelVersion);
	            */
	            //semResult.setTargetObjectId(con.Id);
	            //semResult.setSaveAsActivity(true);
	            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { semResult });
	            
	            delete objEmailCon;
        	}catch(Exception e){
        		
        	}
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'email sent to: '+email));
        }
    }
}