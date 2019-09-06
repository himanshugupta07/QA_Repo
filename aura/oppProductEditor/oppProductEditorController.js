/*
 * oppProductEditorController
*/
({
    handleAddline: function(cmp, event, helper){
        //Add a Blank OpportunityLineItem to the OliList attribute.
        var rows = cmp.get('v.rowCount');
        var rowsInt = cmp.get('v.rowCounter');
        var oliList = cmp.get('v.oliList');
        var addNewOli = "[{'sObjectType': 'OpportunityLineItem' }]";
        
        oliList.push(addNewOli); //Adding to the OliList attribute
        rowsInt++; //Increasing Total OpportunityLineItem Count
        rows.push(rowsInt); //Updating Id list
        
        //Posting back to the Component
        cmp.set('v.oliList',oliList); 
        cmp.set('v.rowCount',rows);
        cmp.set('v.rowCounter',rowsInt);
    },
    handleDuplicate1 : function(component, event, helper) {
        //RowID Event Handler
        //This Functions Checks which button was pressed on the Child Component and does relevant action.
        
        //Fetching values from productField.cmp Event.
        var value = event.getParam("rowToDel"); //RowId
        var thisOli = event.getParam("thisOli"); //Opportunity Line Item from Child Component.
        var isDupe = event.getParam("isDuplicate"); //Gets the Action
        
        //Fetching Values from Component.
        var rows = component.get("v.rowCount"); 
        var rowsInt = component.get('v.rowCounter');
        var oliList = component.get('v.oliList');
        var oliId = oliList[value].Id; //Saving Id
        
        //Handling Duplicate
        if(isDupe == 'Dupe'){
            thisOli.Id=null; 
            
            oliList.push(thisOli); // Push all fields except Id to the New Oli.
            rowsInt++;
            rows.push(rowsInt);
            
            //Posting back to Component
            component.set('v.oliList',oliList);
            component.set('v.rowCount',rows);
            component.set('v.rowCounter',rowsInt);
        }
        
        //Handling Update
        if(isDupe == 'Update'){
            //Syncing changes back to the Oli
            oliList[value] = thisOli;
            oliList[value].Id = oliId;
            oliList[value].Discount_IO__c = 0;
            
            //Posting back to Component
            component.set('v.oliList',oliList);
            component.set('v.rowCount',rows);
            component.set('v.rowCounter',rowsInt);
        }
        //Handling Update
        if(isDupe == 'handleCustPrice'){
            //Syncing changes back to the Oli
            oliList[value] = thisOli;
            oliList[value].Id = oliId;
            
            //Posting back to Component
            component.set('v.oliList',oliList);
            component.set('v.rowCount',rows);
            component.set('v.rowCounter',rowsInt);
        }
        if(isDupe == 'Close'){
            //Handling Close
            
            //Deleting Oli from the Database.
            if( oliId!=null){
                var action = component.get('c.delOli');
                $A.util.removeClass(component.find("spinnerId"), "slds-hide");
                action.setParams({"oliId" : oliId});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    var res = response.getReturnValue();
                    console.log('delete '+state);
                    if (state === "SUCCESS") {
                        rowsInt--;
                        rows.splice(value, 1);
                        oliList.splice(value, 1);
                        //Sync back
                        component.set('v.oliList',oliList);
                        component.set('v.rowCount',rows);
                        component.set('v.rowCounter',rowsInt);
                        console.log(rowsInt);
                        $A.util.addClass(component.find("spinnerId"), "slds-hide");
                    }
                    else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: 'Problem deleting line. \nPlease refresh the page and Try again!',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                });
                $A.enqueueAction(action);
            }
            else{
                rowsInt--;
                rows.splice(value, 1);
                oliList.splice(value, 1);
                //Sync back
                component.set('v.oliList',oliList);
                component.set('v.rowCount',rows);
                component.set('v.rowCounter',rowsInt);
                console.log(rowsInt);
            }
        }
    },
    
    doInit: function (component,event, helper){
        //Initialising
        $A.util.removeClass(component.find("spinnerId2"), "slds-hide");
        var myPageRef = component.get("v.pageReference");
        var firstname = myPageRef.state.c__oppId;
        component.set("v.oppId", firstname);
        
        console.log(component.get('v.recordId'));
        var nAction = component.get('c.getCurrency');
        var actionGrpSale = component.get('c.getGroupSale');
        var oppId = component.get('v.oppId');
        var GS;
        var x;
        component.set('v.recordId',oppId);
        
        actionGrpSale.setParams({"oppId" : oppId});
        actionGrpSale.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                GS = response.getReturnValue();
                x = GS.split(",");
                component.set('v.SalesDept',x[1]);
                if(x[0] === 'Yes'){
                    component.set('v.groupSale',x[0]);
                    component.find("Group_Sale").set("v.value", x[0]);
                }
                else{
                    component.set('v.groupSale',x[0]);
                    component.find("Group_Sale").set("v.value", x[0]);
                }
            }
        });
        $A.enqueueAction(actionGrpSale);
        
        nAction.setParams({"oppId" : oppId});
        nAction.setCallback(this, function(response){
            var currency = response.getReturnValue();
            console.log('currency '+currency);
            component.set('v.opcurncy',currency);
        });
        $A.enqueueAction(nAction);
        
        console.log('oppProductEditor...');
        console.log(component.get('v.recordId'));
        var rows = component.get("v.rowCount");
        var rowsInt = component.get('v.rowCounter');
        var myOli;
        
        //Checking & Fetching LineItems
        if(oppId!=null){
            //Checking for LineItems
            var hasOli;
            var action1 = component.get('c.hasOli');
            action1.setParams({"oppId" : oppId});
            action1.setCallback(this, function(response) {
                hasOli = response.getReturnValue();
            });
            $A.enqueueAction(action1);
            
            //Fetching LineItems
            var action = component.get('c.getOli');
            action.setParams({"oppId" : oppId});
            action.setCallback(this, function(response) {
                action1.setCallback(this, function(response) {
                    if (state === "SUCCESS") {
                        hasOli = response.getReturnValue();
                    }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                            errors[0].message);
                                alert(errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
                });
                $A.enqueueAction(action1);
                if(hasOli=='TRUE'){
                    component.set('v.oliList',response.getReturnValue());
                    myOli = response.getReturnValue();
                }
                var state = response.getState();
                // Callback succeeded
                if ((state === 'SUCCESS') && (response.getReturnValue()!=null) ) {
                    // Get result

                    component.set('v.oliList',response.getReturnValue());
                    $A.util.addClass(component.find("spinnerId2"), "slds-hide");
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                            alert(errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            // Sync Back   
            component.set('v.rowCount',rows);
            component.set('v.rowCounter',rowsInt+1);
            $A.enqueueAction(action);
        }
        //Hiding Toast
        var a = component.get('c.hideComponent');
        $A.enqueueAction(a);
        
    },
    handleGroupSale: function (component,event, helper){
        console.log('groupSale',component.find("Group_Sale").get("v.value"));
        if(component.find("Group_Sale").get("v.value") == 'Yes'){
            component.set('v.groupSale',component.find("Group_Sale").get("v.value"));
        }
        else{
            component.set('v.groupSale',component.find("Group_Sale").get("v.value"));
        }
        console.log(component.get('v.groupSale'));
    },
    handleSave: function (component,event, helper){
        //Save to Database
        //Getting Values from Component
        var action = component.get('c.saveOli');
        var calsaveSchedule = component.get('c.saveSchedule');
        var myOli = component.get('v.oliList');
        var oppId = component.get('v.recordId');
        var count = component.get('v.rowCounter');
        var chk = 1;
        var obj = JSON.stringify(myOli); //Converting to JSON 
        console.log('gs');
        console.log(component.get('v.groupSale'));

	        
        if(!( (component.get('v.groupSale')!=null) && 
            (component.get('v.groupSale')!='None') && 
            (component.get('v.groupSale')!='')) ){
            chk = 2;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message: 'Error: Please select Group Sale!',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
        
        for(var i=0; i<myOli.length ;i++){
            console.log("save Loop");
            console.log(myOli[i].Platform__c);
                        
            if(! ( (myOli[i].Publication__c!=null)&&(myOli[i].Publication__c!='None')&&(myOli[i].Publication__c!='') &&
                  (myOli[i].Edition__c!=null)&&(myOli[i].Edition__c!='None')&&(myOli[i].Edition__c!='') &&
                  (myOli[i].Ad_Size__c!=null)&&(myOli[i].Ad_Size__c!='None')&&(myOli[i].Ad_Size__c!='') ) ){
                chk = 2;
                var err = 'Row: ' + (i+1) + '\nPlease populate all the required fields!';
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: err,
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
                
            }
            
            if( (myOli[i].Platform__c!=null)&&(myOli[i].Platform__c!='None')&&(myOli[i].Platform__c!='') ){
                if( (myOli[i].Platform__c.includes("Print")) ){
                    if(! ((myOli[i].Combined_Audience__c != null) && 
                          (myOli[i].Combined_Audience__c != '') && 
                          (myOli[i].Combined_Audience__c != 'None')) ){
                        
                        chk = 2;
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: 'Error: Combined Audience is Required for Print Products!',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                }
                
                if( (myOli[i].Section__c === 'Promo Opportunity') ){
                    if(! ((myOli[i].Position__c  != null) && 
                          (myOli[i].Position__c  != '') && 
                          (myOli[i].Position__c  != 'None')) ){
                        
                        chk = 2;
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: 'Error: Position is Required for Promo Opportunity!',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                }
            }
        }
        
        
        if( (myOli.length > 0) && (chk != 2) ){
            $A.util.addClass(component.find("edit"), "slds-hide");
        	$A.util.removeClass(component.find("spinnerId"), "slds-hide");
            //Calling Controller Method
            action.setParams({"oli" : obj,
                              "OppId" : oppId,
                              "ISOcurncy" : component.get('v.opcurncy'),
                              "GroupSale" : component.get('v.groupSale'),
                              "SalesDept" : component.get('v.SalesDept')
                             });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(state);
                if (state === "SUCCESS") {
                            calsaveSchedule.setParams({"oppid" : oppId
                                                      });
                            calsaveSchedule.setCallback(this, function(saveScheduleresponse) {
                                var state3 = saveScheduleresponse.getState();
                                console.log(state3);
                                if (state3 === "SUCCESS") {                        
                                    $A.util.addClass(component.find("spinnerId"), "slds-hide");
                                    //Navigate to Opp Detail Page
                                    let stateObject = { foo: "bar" };
                                    history.pushState(stateObject, "page 2", "/lightning/r/Opportunity/"+oppId+"/view");
                                    window.location.reload();
                                }
                                if (state3 === "ERROR") {
                                    $A.util.addClass(component.find("spinnerId"), "slds-hide");
                                    $A.util.removeClass(component.find("edit"), "slds-hide");
                                    var errors = saveScheduleresponse.getError();
                                    if (errors) {
                                        if (errors[0] && errors[0].message) {
                                            console.log("Error message: " + 
                                                        errors[0].message);
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
                            $A.enqueueAction(calsaveSchedule);
                        }
                else{ 
                    $A.util.addClass(component.find("spinnerId"), "slds-hide");
                    $A.util.removeClass(component.find("edit"), "slds-hide");
                    if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                            errors[0].message);
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
                        } else {
                            console.log("Unknown error");
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        }
        
        else{
            if(chk != 2){ 
                //Navigate to Opp Detail Page
                let stateObject = { foo: "bar" };
                history.pushState(stateObject, "page 2", "/lightning/r/Opportunity/"+oppId+"/view");
                window.location.reload();
            }
        }
        
    },
    showComponent : function (component, event, helper) {
        $A.util.addClass(component.find("edit"), "slds-hide");//Hiding Edit Div
        $A.util.removeClass(component.find("success"), "slds-hide");
    },
    hideComponent : function (component, event, helper) {
        $A.util.addClass(component.find("success"), "slds-hide");
        $A.util.addClass(component.find("spinnerId"), "slds-hide");
    },
    handleCancel : function (component, event, helper) {
        //Handle Global Cancel
        var oppId = component.get('v.recordId');
        
        let stateObject = { foo: "bar" };
        history.pushState(stateObject, "page 2", "/lightning/r/Opportunity/"+oppId+"/view");
        window.location.reload();
    },
    getRecordId : function (component, event, helper) {
        console.log("IO");
        var value = event.getParam("OppId");
        console.log("IO"+OppId);
        component.set('v.recordId');
    }
})