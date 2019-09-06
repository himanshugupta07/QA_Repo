({
    showComponent: function(component, event, helper) {
        $A.util.addClass(component.find("edit"), "slds-hide"); //Hiding Edit Div
        $A.util.removeClass(component.find("success"), "slds-hide");
    },
    hideComponent: function(component, event, helper) {
        $A.util.addClass(component.find("success"), "slds-hide");
    },
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true);
    },

    // this function automatic call by aura:doneWaiting event 
    hideSpinner: function(component, event, helper) {
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
        //$A.util.removeClass(component.find("success"), "slds-hide");
    },
    closeFocusedTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})