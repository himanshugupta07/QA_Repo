({
    doInit: function(component, event, helper) {
        var cOli = component.get('v.oli');

        $A.util.addClass(component.find("NonIOProd"), "slds-hide");
        console.log('cOli.lineItem.Print_IO__c',cOli.Print_IO__c);
        if(!cOli.Print_IO__c){
            $A.util.removeClass(component.find("NonIOProd"), "slds-hide");
            $A.util.addClass(component.find("IOtool"), "slds-hide");
        }
    },
    handleSplit: function(component, event, helper) {
        var index = component.get("v.rowId");
        var myEvent = component.getEvent("RowID");
        //Exporting rowId and Oli to be duplicated.
        myEvent.setParams({
            rowToDel: index,
            isDuplicate: "Split",
            thisOli: component.get("v.oli")
        });
        myEvent.fire();
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
   	priceHandler: function(component, event, helper) {
        //Handling Discount Change
        var oli = component.get("v.oli");
        var ISOcurncy = component.get("v.crncy");
        var index = component.get("v.rowId");
        var custPrice;
        console.log(oli.Print_IO__c);
        if(!oli.Print_IO__c){
        custPrice = component.find("currency__c").get("v.value");
            console.log('Prnt '+custPrice);
        }
        else{
            custPrice = component.find("currency__c2").get("v.value");
        }
        //var unitPrice = component.find("UnitPrice").get("v.value");
        
        var isErr = 0;
        var errmsg = "";
        
        if(custPrice.length < 4){
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
        }
        else{
            if((isErr != 2) && (isErr != 4)){
                isErr = 2;
                errmsg = "Enter a Value";
                console.log(isErr+errmsg);
            }
        }
        if((( custPrice % 1 !== 0 ) || (custPrice % 1 === 0)) && (isErr == 0) && (typeof custPrice != 'string') ){
            //Accounting Discount & normalising it
            console.log('custPrice'+typeof custPrice);
            oli.currency__c = component.get("v.crncy") + " " + custPrice;
            //oli.Discount = discount;
            //oli.Discount_IO__c = discount;
            //Post back
            component.set("v.oli", oli);
        }
        else{
            if( (typeof custPrice == 'string') && (custPrice.length >3)){
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
                oli.currency__c = component.get("v.crncy") + " ";
            }
            else{
                oli.currency__c = component.get("v.crncy") + " ";
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
    }
})