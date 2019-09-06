({
    showComponent : function (component, event, helper) {
        var Opprec  = component.get("v.recordId");
        var sObectEvent = $A.get("e.force:navigateToSObject");
        sObectEvent .setParams({
            "recordId": Opprec
        });
        sObectEvent.fire(); 
    },
    doInit : function (component, event, helper) {
        var oppId=component.get('v.recordId');
        var getName = component.get('c.getOppName');
        getName.setParams({"oppId" : oppId});
        getName.setCallback(this, function(response) {
            console.log('oppName',response.getReturnValue());
            component.set('v.oppName',response.getReturnValue());
        });
        $A.enqueueAction(getName);    
        console.log('TOAST'+component.get('v.recordId')+' '+component.get('v.status'));
    }
})