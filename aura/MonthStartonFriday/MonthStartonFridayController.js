({
	showComponent : function (component, event, helper) {
        console.log('I AM showComponent addClass '+event.currentTarget.value+event.currentTarget.id);
        var elements = document.getElementsByClassName("slds-is-selected");
        var sel = parseInt(event.currentTarget.id);
        var pub = component.get('v.publication');
        var daysinmnth = parseInt(component.get('v.mnthDays'));
        if(((daysinmnth>=28) && (daysinmnth<31)) && ((sel==29) )){
            
        }
        else{
            if((pub == "The Economist Newspaper")||(pub == "The Economist Digital Editions")){
                if((sel==2)||(sel==9)||(sel==16)||(sel==23)||(sel==30)){
                    $A.util.addClass(component.find(sel), "slds-is-selected");
                    console.log("elements.length: " + elements.length);
                    for (var i=0; i<elements.length; i++) {
                        console.log(elements[i].id);
                        $A.util.removeClass(component.find(elements[i].id), "slds-is-selected");
                    }
                    var myEvent = component.getEvent("dateDay");
                    myEvent.setParams({"upday": parseInt(sel)});
                    myEvent.fire();
                }
            }
            if(pub == "Espresso"){
                    if((sel==4)||(sel==11)||(sel==18)||(sel==25)){
                        $A.util.addClass(component.find(sel), "slds-is-selected");
                        console.log("elements.length: " + elements.length);
                        for (var i=0; i<elements.length; i++) {
                            console.log(elements[i].id);
                            $A.util.removeClass(component.find(elements[i].id), "slds-is-selected");
                        }
                        var myEvent = component.getEvent("dateDay");
                        myEvent.setParams({"upday": parseInt(sel)});
                        myEvent.fire();    
                    }
            }
            if(pub == "GBR"){
                    if(sel==1){
                        $A.util.addClass(component.find(sel), "slds-is-selected");
                        console.log("elements.length: " + elements.length);
                        for (var i=0; i<elements.length; i++) {
                            console.log(elements[i].id);
                            $A.util.removeClass(component.find(elements[i].id), "slds-is-selected");
                        }
                        var myEvent = component.getEvent("dateDay");
                        myEvent.setParams({"upday": parseInt(sel)});
                        myEvent.fire();    
                    }
            }
            else{
                $A.util.addClass(component.find(sel), "slds-is-selected");
                for (var i=0; i<elements.length; i++) {
                    console.log(elements[i].id);
                    $A.util.removeClass(component.find(elements[i].id), "slds-is-selected");
                }
                var myEvent = component.getEvent("dateDay");
                myEvent.setParams({"upday": parseInt(sel)});
                myEvent.fire(); 
            }
        }
        console.log('evnt fired'+parseInt(sel));
	},
    doInit : function (component, event, helper) {
        var s = component.get('v.today');
        var d = parseInt(s);
        console.log('FRIDAYinit'+s+d);
        var a = component.get('c.activeDays');
        $A.enqueueAction(a);
    },
    activeDays : function (component, event, helper) {
        var pub = component.get('v.publication');
        var daysinmnth = parseInt(component.get('v.mnthDays'));
        var day = 1;
        if(daysinmnth == 28){
            $A.util.addClass(component.find(29), "slds-hide");
            $A.util.addClass(component.find(30), "slds-hide");
            $A.util.addClass(component.find(31), "slds-hide");
        }
        if(daysinmnth == 29){
            $A.util.addClass(component.find(30), "slds-hide");
            $A.util.addClass(component.find(31), "slds-hide");
        }
        if(daysinmnth == 30){
            $A.util.addClass(component.find(31), "slds-hide");
        }
        if((pub == "The Economist Newspaper")||(pub == "The Economist Digital Editions")){
            for(day =1; day<=daysinmnth;day++){
                if((day==2)||(day==9)||(day==16)||(day==23)||(day==30)){
                }
                else{
                $A.util.addClass(component.find(day), "slds-disabled-text");
                }
            }
        }
        if(pub == "Espresso"){
            for(day =1; day<=daysinmnth;day++){
                if((day==4)||(day==11)||(day==18)||(day==25)){
                }
                else{
                    $A.util.addClass(component.find(day), "slds-disabled-text");
                }
            }
        }
        if(pub == "GBR"){
            for(day =2; day<=daysinmnth;day++){
                    $A.util.addClass(component.find(day), "slds-disabled-text");
            }
        }
    }
})