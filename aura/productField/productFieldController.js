({
    priceCalc: function(component, event, helper) {
        //Fetching Prices from Salesforce
        var OppliID =
            component.get("v.oliId") != null ? component.get("v.oliId") : "BLANK";
        var index = component.get("v.rowId");
        var myEvent = component.getEvent("RowID");
        var oli = component.get("v.oli");
        var oppId = component.get("v.oppId");
        var adsz = component.find("Ad_Size__c").get("v.value");
        var edtn = component.find("Edition__c").get("v.value");
        var pub = component.find("Publication__c").get("v.value");
        
        console.log('adzise',component.find("Ad_Size__c").get("v.value"),component.get("v.SalesDept"));
        
        //Updating Oli with the changes
        oli = {
            Publication__c: component.find("Publication__c").get("v.value"),
            Issue_Date__c: component.find("Issue_Date__c").get("v.value"),
            Section__c: component.find("Section__c").get("v.value"),
            Platform__c: component.find("Platform__c").get("v.value"),
            Edition__c: component.find("Edition__c").get("v.value"),
            Ad_Size__c: component.find("Ad_Size__c").get("v.value"),
            Requested_Gauranted__c: component.find("Requested_Gauranted__c").get("v.value"),
            Position__c: component.find("Position__c").get("v.value"),
            Color__c: component.find("Color__c").get("v.value"),
            Discount: Number.parseFloat(
                component.find("Discount_IO__c").get("v.value")
            ),
            UnitPrice: component.find("UnitPrice").get("v.value"),
            Discount_IO__c: component.find("Discount_IO__c").get("v.value"),
            Id: OppliID,
            Combined_Audience__c : component.find("Combined_Audience__c").get("v.value")
        };
        
        //Calling apex to getPrice from Product Reference Cards
        if( (typeof adsz !== 'undefined')&&(adsz!=null)&&(adsz!='None')&&(adsz!='')&&(adsz!='NONE')
           &&(edtn!='NONE')&&(edtn!=null)&&(pub!=null)&&(pub!='NONE')){
            console.log('inside IF');
            var action = component.get("c.getPrice");
            var obj = JSON.stringify(oli);
            action.setParams({
                oli: obj,
                ISOcurncy: component.get("v.crncy"),
                OppId: oppId,
                SalesDept: component.get("v.SalesDept")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var updtoli = response.getReturnValue();
                    //Ensuring Oli has Id
                    if (OppliID != null && OppliID != "BLANK"){
                        updtoli.Id = OppliID;
                    }
                    //Triggering Event to send everything back to Parent Component
                    myEvent.setParams({
                        rowToDel: index,
                        isDuplicate: "Update",
                        thisOli: updtoli
                    });
                    myEvent.fire();
                    if(updtoli.UnitPrice === 0){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: 'Prices not available.\nPlease check with Ad Control for Pricing!',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            //alert(errors[0].message);
                            var e = "Error message: " + errors[0].message;
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: e,
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        }
        else{
            //Triggering Event to send everything back to Parent Component
            myEvent.setParams({
                rowToDel: index,
                isDuplicate: "Update",
                thisOli: oli
            });
            myEvent.fire();
        }
    },
    
    doInit: function(component, event, helper) {
        //Initialising Component
        console.log('doInit'+component.get("v.oppId"));
        var oli = component.get("v.oli");
        var print = component.find("Platform__c").get("v.value");
        var oppId = component.get("v.oppId");
        console.log(oli);
        
        if(oppId!=null){
            var action = component.get("c.getPrice");
            var obj = JSON.stringify(oli);
            action.setParams({
                oli: obj,
                ISOcurncy: component.get("v.crncy"),
                OppId: oppId,
                SalesDept: component.get("v.SalesDept")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var updtoli = response.getReturnValue();
                    component.set("v.unitPriceSvd",updtoli.UnitPrice);
                }
            });
            $A.enqueueAction(action);
        }
        
        if (oli.Id != null) {
            component.find("Publication__c").set("v.value", oli.Publication__c);
            component.find("Issue_Date__c").set("v.value", oli.Issue_Date__c);
            component.find("Platform__c").set("v.value", oli.Platform__c);
            component.find("Edition__c").set("v.value", oli.Edition__c);
            component.find("Ad_Size__c").set("v.value", oli.Ad_Size__c);
            component.find("Requested_Gauranted__c").set("v.value", oli.Requested_Gauranted__c);
            component.find("Position__c").set("v.value", oli.Position__c);
            component.find("Color__c").set("v.value", oli.Color__c);
            component.find("Discount").set("v.value", oli.Discount);
            component.find("UnitPrice").set("v.value", oli.UnitPrice);
            component.find("currency__c").set("v.value", oli.currency__c);
            console.log("INIT");
            console.log(oli.UnitPrice+" "+oli.currency__c);
            component.find("Discount_IO__c").set("v.value", oli.Discount_IO__c);
            component.find("Combined_Audience__c").set("v.value",oli.Combined_Audience__c);
            if((oli.Platform__c).includes("Print")){
                $A.util.removeClass(component.find("combinedaudience"), "slds-hide");
            }
            else{
                $A.util.addClass(component.find("combinedaudience"), "slds-hide");
            }
        }
        else{
            if( (print!=null)&&(print!='None')&&(print!='') ){
                if( (print.includes("Print")) || (oli.Platform__c).includes("Print") ){
                    $A.util.removeClass(component.find("combinedaudience"), "slds-hide");
                }
                else{	
                    $A.util.addClass(component.find("combinedaudience"), "slds-hide");
                }
            }else{	
                $A.util.addClass(component.find("combinedaudience"), "slds-hide");
            }
        }
    },
    handleClose: function(component, event, helper) {
        //Handling Close
        var index = component.get("v.rowId");
        var myEvent = component.getEvent("RowID");
        //Exporting Row and Oli to be removed from List and Database.
        myEvent.setParams({
            rowToDel: index,
            isDuplicate: "Close",
            thisOli: component.get("v.oli")
        });
        var r = confirm("This will permanently delete this Line Item. Do you still want to continue?");
        if(r == true){
            myEvent.fire();
        }
    },
    handleDuplicate: function(component, event, helper) {
        //Handling Duplicate
        var index = component.get("v.rowId");
        var myEvent = component.getEvent("RowID");
        //Exporting rowId and Oli to be duplicated.
        myEvent.setParams({
            rowToDel: index,
            isDuplicate: "Dupe",
            thisOli: component.get("v.oli")
        });
        myEvent.fire();
    },
    handleSelection: function(component, event, helper) {
        //Update Selected date to Oli
        component.set("v.oli.Issue_Date__c", event.getParam("issueDate"));
    },
    pubChange: function(component, event, helper) {
        //Handling Publication Picklist Changes and Updating Issue Dates accordingly.
        var Publication = component.find("Publication__c").get("v.value");
        var oli = component.get("v.oli");
        var index = component.get("v.rowId");
        //Cleansing everything
        if (Publication != null) {
            oli.Publication__c = Publication;
            oli.Issue_Date__c = " ";
            oli.Requested_Gauranted__c = "";
            oli.Ad_Size__c = "";
            oli.Section__c = "";
            oli.UnitPrice = 0;
            oli.currency__c = 0;
            oli.Position__c = "";
            oli.Discount_IO__c = 0;
            oli.Platform__c = "";
            oli.Edition__c = "";
            oli.Color__c = "";
            oli.Combined_Audience__c = "";
            //Sync back to Parent
            var myEvent = component.getEvent("RowID");
            myEvent.setParams({
                rowToDel: index,
                isDuplicate: "Update",
                thisOli: oli
            });
            myEvent.fire();
        }
    },
    editionChange: function(component, event, helper) {
        var OppliID = component.get("v.oliId") != null ? component.get("v.oliId") : "BLANK";
        var index = component.get("v.rowId");
        var myEvent = component.getEvent("RowID");
        var oli = component.get("v.oli");
        var oppId = component.get("v.oppId");
        var edtn = component.find("Edition__c").get("v.value");
        var adsz = component.find("Ad_Size__c").get("v.value");
        var pub = component.find("Publication__c").get("v.value");
        console.log('Edition'+edtn);
        
        oli = {
            Publication__c: component.find("Publication__c").get("v.value"),
            Issue_Date__c: component.find("Issue_Date__c").get("v.value"),
            Section__c: component.find("Section__c").get("v.value"),
            Platform__c: component.find("Platform__c").get("v.value"),
            Edition__c: component.find("Edition__c").get("v.value"),
            Ad_Size__c: component.find("Ad_Size__c").get("v.value"),
            Requested_Gauranted__c: component.find("Requested_Gauranted__c").get("v.value"),
            Position__c: component.find("Position__c").get("v.value"),
            Color__c: component.find("Color__c").get("v.value"),
            Discount: Number.parseFloat(
                component.find("Discount_IO__c").get("v.value")
            ),
            UnitPrice: component.find("UnitPrice").get("v.value"),
            Discount_IO__c: component.find("Discount_IO__c").get("v.value"),
            Id: OppliID,
            Combined_Audience__c : component.find("Combined_Audience__c").get("v.value")
        };
        
        //Calling apex to getPrice from Product Reference Cards
        if( (typeof adsz !== 'undefined')&&(adsz!=null)&&(adsz!='None')&&(adsz!='')&&(adsz!='NONE')
           &&(edtn!='NONE')&&(edtn!=null)&&(pub!=null)&&(pub!='NONE')){
            console.log('inside IF');
            var action = component.get("c.getPrice");
            var obj = JSON.stringify(oli);
            action.setParams({
                oli: obj,
                ISOcurncy: component.get("v.crncy"),
                OppId: oppId,
                SalesDept: component.get("v.SalesDept")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var updtoli = response.getReturnValue();
                    //Ensuring Oli has Id
                    if (OppliID != null && OppliID != "BLANK"){
                        updtoli.Id = OppliID;
                    }
                    //Triggering Event to send everything back to Parent Component
                    myEvent.setParams({
                        rowToDel: index,
                        isDuplicate: "Update",
                        thisOli: updtoli
                    });
                    myEvent.fire();
                    if(updtoli.UnitPrice === 0){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: 'Prices not available.\nPlease check with Ad Control for Pricing!',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            //alert(errors[0].message);
                            var e = "Error message: " + errors[0].message;
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: e,
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    discountHandler: function(component, event, helper) {
        //Handling Discount Change
        var index = component.get("v.rowId");
        var oli = component.get("v.oli");
        var isErr = 0;
        var errMsg = "";
        var dis = component.find("Discount_IO__c").get("v.value");
        var discount = Number.parseFloat(
            component.find("Discount_IO__c").get("v.value")
        );
        var unitPrice = component.get("v.unitPriceSvd");
        var price = Number(Math.round(unitPrice - (unitPrice * discount) / 100 + "e2") + "e-2");
        
        price = Number(Math.round(unitPrice - (unitPrice * discount) / 100 + "e2") + "e-2");
        //Accounting Discount & normalising it
        oli.currency__c = component.get("v.crncy") + " " + price;
        oli.Discount = discount;
        
        
        if (discount == "NaN"){
            //Null check
            discount = 0;
        }
        if (price == "NaN"){
            //Null check
            price = 0;
        }
        //Post back
        component.set("v.oli", oli);
        
        if(!discount){
            if(dis.length == 0){
                isErr = 4;
                console.log(isErr+errMsg);
            }
            if(Number.isNaN(discount) && (isErr == 0)){
                isErr = 3;
                errMsg = 'Enter Integers Only!!';
                console.log(isErr+errMsg);
                if(typeof dis == 'string'){
                    isErr = 2;
                    errMsg = 'Enter Integers Only!!';
                    console.log(isErr+errMsg);
                }
            }
            oli.currency__c = component.get("v.crncy") + " " + component.find("UnitPrice").get("v.value");
            //Post back
            component.set("v.oli", oli);
        }
        
        if( (isErr == 2) || (isErr == 3) ){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message: errMsg,
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
        if(discount > 100 ){
            discount = parseInt(discount/10);
            console.log(discount);
            oli.Discount = discount;
            oli.Discount_IO__c = discount;
            price = 0;
            oli.currency__c = Number(Math.round(unitPrice - (unitPrice * discount) / 100 + "e2") + "e-2");
            
            var myEvent = component.getEvent("RowID");
            myEvent.setParams({
                rowToDel: index,
                isDuplicate: "handleCustPrice",
                thisOli: oli
            });
            myEvent.fire();
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message: 'Discount can not be greater than 100%',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }                    
    },
    priceHandler: function(component, event, helper) {
        //Handling Discount Change
        var oli = component.get("v.oli");
        var ISOcurncy = component.get("v.crncy");
        var index = component.get("v.rowId");
        var test = component.find("Discount_IO__c").get("v.value");
        console.log('test'+typeof test);
        var discount = Number.parseFloat(
            component.find("Discount_IO__c").get("v.value")
        );
        var unitPrice = component.get("v.unitPriceSvd");
        var custPrice = component.find("currency__c").get("v.value");
        var isErr = 0;
        var errmsg = "";
        
        if(!(custPrice.includes(" "))){
           	isErr = 4;
           	oli.currency__c = ISOcurncy + " ";
           	component.set("v.oli", oli);
        	errmsg = "Oops! Space is needed between Currency Code and Amount";
        	console.log(isErr+errmsg);
        }
        
        if( (custPrice.length < 4) && (isErr == 0) ){
            isErr = 4;
            oli.currency__c = ISOcurncy + " ";
            component.set("v.oli", oli);
            errmsg = "Oops! Currency is needed.";
            console.log(isErr+errmsg);
        }
        if((custPrice.includes(" ")) && (isErr == 0)){
            if(custPrice.length > 4){
                var x = custPrice.split(" ");
                console.log('x'+typeof x[1]);
                custPrice = Number.parseFloat(x[1]);
                if( Number.isNaN(custPrice) ){
                    oli.currency__c = component.get("v.crncy") + " ";
                    //component.set("v.oli", oli);
                    
                    var myEvent = component.getEvent("RowID");
                    myEvent.setParams({
                        rowToDel: index,
                        isDuplicate: "Update",
                        thisOli: oli
                    });
                    myEvent.fire();
                    
                    isErr = 2;
                    errmsg = "Enter a Valid Value";
                    console.log(isErr+errmsg);
                }
            }
            console.log('UnitPrice '+ unitPrice+ ' CUSTOM ' + custPrice);
        }
        else{
            if((isErr != 2) && (isErr != 4)){
                isErr = 2;
                errmsg = "Enter a Value";
                console.log(isErr+errmsg);
            }
        }
        if((( custPrice % 1 !== 0 ) || (custPrice % 1 === 0)) && (isErr == 0) && (typeof custPrice != 'string') ){
            if((unitPrice!=0) && (custPrice<=unitPrice)){
                
                discount = Number(Math.round((((unitPrice - custPrice)/unitPrice)*100) + "e2") + "e-2");
                console.log('dis'+discount);
            }
            else{
                discount = 0;
            }
            //Accounting Discount & normalising it
            console.log('custPrice'+typeof custPrice);
            oli.currency__c = component.get("v.crncy") + " " + custPrice;
            oli.Discount = discount;
            oli.Discount_IO__c = discount;
            //Post back
            component.set("v.oli", oli);
        }
        else{
            if( (typeof custPrice == 'string') && (custPrice.length >3) && (isErr != 4)){
                console.log('Length '+custPrice.length);
                isErr = 5;
            }
            if((isErr != 2) && (isErr != 4) && (isErr != 5) ){
                isErr = 1;
                errmsg = "Enter a Integer Value";
                console.log(isErr+errmsg);
            }
        }
        
        if((isErr == 1) || (isErr == 2) || (isErr == 4) ){
            if(isErr != 4){
                oli.currency__c = component.get("v.crncy") + " " + unitPrice;
                oli.Discount = discount;
                oli.Discount_IO__c = discount;
            }
            else{
                oli.currency__c = component.get("v.crncy") + " ";
                oli.Discount = discount;
                oli.Discount_IO__c = discount;
            }
            var myEvent = component.getEvent("RowID");
            myEvent.setParams({
                rowToDel: index,
                isDuplicate: "Update",
                thisOli: oli
            });
            myEvent.fire();
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message: errmsg,
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
    },
    combinedAudHandler: function(component, event, helper) {
        var print = component.find("Platform__c").get("v.value");
        console.log('printPQ'+print);
        if( (print!=null)&&(print!='None')&&(print!='') ){
            if( (print.includes("Print")) ){
                $A.util.removeClass(component.find("combinedaudience"), "slds-hide");
            }
            else{
                $A.util.addClass(component.find("combinedaudience"), "slds-hide");
            }
        }
    }
});