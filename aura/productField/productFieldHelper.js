({
    removeLead : function(component, index) {
        var leads = component.get("v.rowCount");
        leads.splice(index, 1);
        component.set("v.rowCount", leads);
    }
})