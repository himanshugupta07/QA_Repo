({
    doInit : function(component, event, helper) {
        var pub = component.get('v.publication');
        var pclst;
        var list;
        
        var action = component.get('c.getIssueDates');
        action.setParams({"pub" : pub
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(	response.getReturnValue());
                list = response.getReturnValue();
                pclst = list.split(',');
                pclst.pop(); 
                component.set("v.picklistValues", pclst);
                console.log(pclst);
            }
        });
        $A.enqueueAction(action);
        
    },
    handleSelect : function(component, event, helper) {
        var elements = document.getElementsByClassName("slds-is-selected");
        var sel = parseInt(event.currentTarget.id)
        var selval = component.get("v.picklistValues");
        
        $A.util.addClass(component.find(event.currentTarget.id), "slds-is-selected");
        
        for (var i=0; i<elements.length; i++) {
            $A.util.removeClass(component.find(elements[i].id), "slds-is-selected");
        }
        var myEvent = component.getEvent("parseDate");
        myEvent.setParams({"mdtDate": selval[sel]});
        myEvent.fire();
        
        
    }
})