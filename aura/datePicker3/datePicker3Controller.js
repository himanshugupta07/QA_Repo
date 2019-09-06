({
    showComponent : function (component, event, helper) {
        console.log('I AM showComponent addClass');
        $A.util.addClass(component.find("25"), "slds-is-selected");
        component.set('v.selDate',"25");
        
        $A.util.removeClass(component.find("success"), "slds-hide");
    },
    doInit : function(component, event, helper){
        var myDate;
        var str_array;
        var sel = component.get('v.selDate');
        console.log('pub'+component.get('v.publication'));
        var d = new Date();
        var str = d.toString().split(' ');
        
        console.log('DPINIT '+d+str);
        var action = component.get('c.getToday');
        action.setParams({"Day" : parseInt(str[2]),
                          "Month" : str[1],
                          "Year" : parseInt(str[3])});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('handleSave response.getState(); ',response.getState(),' val ',response.getReturnValue());
                myDate = response.getReturnValue();
                str_array = myDate.split(',');
                component.set('v.mnthsrtDay',str_array[0]);
                component.set('v.daysinMnth',parseInt(str_array[1]));
                component.set('v.month',str_array[2]);
                component.set('v.day',parseInt(str_array[3]));
                component.set('v.year',parseInt(str_array[4]));
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
        
        console.log($A.localizationService.formatDate(sel, "dd MMM yyyy"));
        component.set('v.selDate',sel);
        //component.set('v.selDate',$A.localizationService.formatDate(sel, "dd MMM yyyy")) ;
        
    },
    monthChangegt : function(component, event, helper){
        var mnth = component.get('v.month');
        var yrs = component.get('v.year');
        
        console.log('gt');
        if(mnth=='Jan')
            component.set('v.month','Feb');
        if(mnth=='Feb')
            component.set('v.month','Mar');
        if(mnth=='Mar')
            component.set('v.month','Apr');
        if(mnth=='Apr')
            component.set('v.month','May');
        if(mnth=='May')
            component.set('v.month','Jun');
        if(mnth=='Jun')
            component.set('v.month','Jul');   
        if(mnth=='Jul')
            component.set('v.month','Aug');
        if(mnth=='Aug')
            component.set('v.month','Sep');
        if(mnth=='Sep')
            component.set('v.month','Oct');
        if(mnth=='Oct')
            component.set('v.month','Nov');
        if(mnth=='Nov')
            component.set('v.month','Dec');
        if(mnth=='Dec'){
            component.set('v.month','Jan');
            console.log('dec');
            yrs++;
            component.set('v.year',yrs);
        }
        
        var a = component.get('c.updateDate');
        $A.enqueueAction(a);     
    },
    monthChangelt : function(component, event, helper){
        var mnth = component.get('v.month');
        var yrs = component.get('v.year');
        console.log('lt'+mnth);
        if(mnth=='Jan'){
            component.set('v.month','Dec');
            yrs--;
            component.set('v.year',yrs);
        }
        if(mnth=='Feb')
            component.set('v.month','Jan');
        if(mnth=='Mar')
            component.set('v.month','Feb');
        if(mnth=='Apr')
            component.set('v.month','Mar');
        if(mnth=='May')
            component.set('v.month','Apr');
        if(mnth=='Jun')
            component.set('v.month','May');   
        if(mnth=='Jul')
            component.set('v.month','Jun');
        if(mnth=='Aug')
            component.set('v.month','Jul');
        if(mnth=='Sep')
            component.set('v.month','Aug');
        if(mnth=='Oct')
            component.set('v.month','Sep');
        if(mnth=='Nov')
            component.set('v.month','Oct');
        if(mnth=='Dec')
            component.set('v.month','Nov');
        
        var a = component.get('c.updateDate');
        $A.enqueueAction(a);             
    },
    yeargt : function(component, event, helper){
        var yrs = component.get('v.year');
        yrs++;
        console.log(component.get('v.year')+yrs+component.get('v.month')+component.get('v.day'));
        component.set('v.year',yrs);     
        
        var a = component.get('c.updateDate');
        $A.enqueueAction(a); 
    },
    yearlt : function(component, event, helper){
        var yrs = component.get('v.year');
        yrs--;
        console.log(component.get('v.year')+yrs);
        component.set('v.year',yrs); 
        
        var a = component.get('c.updateDate');
        $A.enqueueAction(a); 
    },
    updateDate : function(component, event, helper){
        var myDate;
        var str_array;
        var action = component.get('c.getToday');
        action.setParams({"Day" : component.get('v.day'),
                          "Month" : component.get('v.month'),
                          "Year" : component.get('v.year')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('handleSave response.getState(); ',response.getState(),' val ',response.getReturnValue());
                myDate = response.getReturnValue();
                str_array = myDate.split(',');
                component.set('v.mnthsrtDay',str_array[0]);
                component.set('v.daysinMnth',str_array[1]);
                component.set('v.month',str_array[2]);
                component.set('v.day',str_array[3]);
                component.set('v.year',str_array[4]);
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
    },
    handleSelection : function(component, event, helper){
        var action = component.get('c.getsfDate');
        action.setParams({"Day" : event.getParam("upday"),
                          "Month" : component.get('v.month'),
                          "Year" : component.get('v.year')});
        action.setCallback(this, function(response) {
            component.set('v.selDate',$A.localizationService.formatDate(response.getReturnValue(), "dd MMM yyyy"));
            
            var myEvent = component.getEvent("isueDate");
            myEvent.setParams({"issueDate": response.getReturnValue()});
            myEvent.fire();
        });
        $A.util.addClass(component.find("datePicker"), "slds-hide");
        $A.enqueueAction(action);
        
        
    },
    showdatePicker : function(component, event, helper){
        $A.util.removeClass(component.find("datePicker"), "slds-hide");
    },
    updateSelection : function(component, event, helper){
        var dt = event.getParam("mdtDate");
        console.log('updateSelection: '+ dt);
        component.set('v.selDate',$A.localizationService.formatDate(dt, "dd MMM yyyy"));
        var myEvent = component.getEvent("isueDate");
        myEvent.setParams({"issueDate": event.getParam("mdtDate")});
        myEvent.fire();
    },
    handlefilmSelect : function(component, event, helper){
    	var selval = component.find("filmdate").get("v.value");
        console.log('valfilm',component.find("filmdate").get("v.value"));
        var myEvent = component.getEvent("isueDate");
        myEvent.setParams({"issueDate": event.getParam("selval")});
        myEvent.fire();
    }
})