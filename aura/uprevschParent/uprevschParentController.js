({
    doInit: function (component,event, helper){
        //Initialising
        var myPageRef = component.get("v.pageReference");
        var firstname = myPageRef.state.c__oppId;
        component.set("v.oppId", firstname);
        var myOli;
        var oppId = component.get('v.oppId');
        
        var nAction = component.get('c.getCurrency');
        nAction.setParams({"oppId" : oppId});
        nAction.setCallback(this, function(response){
            var currency = response.getReturnValue();
            console.log('currency '+currency);
            component.set('v.opcurncy',currency);
        });
        $A.enqueueAction(nAction);
        
        //getCloseDate
        var nAction1 = component.get('c.getCloseDate');
        nAction1.setParams({"oppId" : oppId});
        nAction1.setCallback(this, function(response){
            var clsdate = response.getReturnValue();
            console.log('closeDate '+clsdate);
            component.set('v.closeDate',clsdate);
        });
        $A.enqueueAction(nAction1);
        
        
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
            var action = component.get('c.getOli2');
            action.setParams({"oppId" : oppId});
            action.setCallback(this, function(response) {
                action1.setCallback(this, function(response) {
                    hasOli = response.getReturnValue();
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
                    console.log(response.getReturnValue());
                    $A.util.addClass(component.find("spinnerId"), "slds-hide");
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        }
        
    },
    handleSave: function (component,event, helper){
        //Save to Database
        //Getting Values from Component
        var action = component.get('c.handleRevSchUpdates');
        var action2 = component.get('c.handleRevSchUpdateOli');
        var action3 = component.get('c.updClosedateCheck');
        var myOli = component.get('v.oliList');
        var oppId = component.get('v.oppId');
        var obj = JSON.stringify(myOli); //Converting to JSON 
        console.log(obj);
        console.log(myOli);
        $A.util.addClass(component.find("edit"), "slds-hide");
        $A.util.removeClass(component.find("spinnerId"), "slds-hide");
        //Calling Controller Method
        action.setParams({"oli" : obj,
                          "oppId" : oppId,
                          "closeDate" : component.get('v.closeDate')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                action2.setParams({"oppId" : oppId});
                action2.setCallback(this, function(response2) {
                    var state2 = response2.getState();
                    if (state2 === "SUCCESS") {
                        action3.setParams({"oppId" : oppId});
                        action3.setCallback(this, function(response2) {
                        	var state3 = response2.getState();
                            if (state3 === "SUCCESS") {
                                $A.util.addClass(component.find("spinnerId"), "slds-hide");
                                //Navigate to Opp Detail Page
                                let stateObject = { foo: "bar" };
                                history.pushState(stateObject, "page 2", "/lightning/r/Opportunity/"+oppId+"/view");
                                window.location.reload();
                            }
                            else{
                                $A.util.removeClass(component.find("edit"), "slds-hide");
                                $A.util.addClass(component.find("spinnerId"), "slds-hide");
                                if (state === "ERROR") {
                                    var errors = response.getError();
                                    if (errors) {
                                        var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            title : 'Error',
                                            message: 'Error while saving Records!!',
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
                        $A.enqueueAction(action3);
                    }
                    else{
                        $A.util.removeClass(component.find("edit"), "slds-hide");
                        $A.util.addClass(component.find("spinnerId"), "slds-hide");
                        if (state === "ERROR") {
                            var errors = response.getError();
                            if (errors) {
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : 'Error',
                                    message: 'Error while saving Records!!',
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
                $A.enqueueAction(action2);
                }
            else{
                $A.util.removeClass(component.find("edit"), "slds-hide");
                $A.util.addClass(component.find("spinnerId"), "slds-hide");
                if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: 'Error while saving Records!!',
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
    },
    addrevscheditor : function (component, event, helper) {
    	var toastEvent = $A.get("e.force:showToast");
        console.log(component.get("v.Id"));
        toastEvent.setParams({
            title : 'Warning',
            message: 'Please change Revenue Schedules! If Needed',
            duration:' 5000',
            key: 'info_alt',
            type: 'warning',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    handleCancel : function (component, event, helper) {
        //Handle Global Cancel
        var oppId = component.get('v.oppId');
        //Navigate to Opp Detail Page
        let stateObject = { foo: "bar" };
        history.pushState(stateObject, "page 2", "/lightning/r/Opportunity/"+oppId+"/view");
        window.location.reload();
    },
    handleSplit1 : function(component, event, helper) {
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
        var oliId = oliList[value].Id;
        var RevSchId = oliList[value].RevSchId__c; //Saving Id
        
        if(isDupe == 'Split'){
            
            thisOli.RevSchId__c = null;
            thisOli.currency__c = component.get("v.opcurncy")+ " ";
            thisOli.Issue_Date__c = "";
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
        
        if(isDupe == 'Close'){
            //Handling Close
            
            //Deleting Oli from the Database.
            if( RevSchId!=null){
                var action = component.get('c.delRevSch');
                $A.util.removeClass(component.find("spinnerId"), "slds-hide");
                action.setParams({"oliId" : oliId,
                                  "RevSchId" : RevSchId});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    var res = response.getReturnValue();
                    console.log('delete '+state);
                    if (state === "SUCCESS") {
                        if(res === 'TRUE'){
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
                                message: 'You can not delete all the Revenue Schedules of a Product! Please edit the product, if needed',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                            $A.util.addClass(component.find("spinnerId"), "slds-hide");
                        }
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
    }
})