var isInGroundStash = false;
var currentGroundStashID = 0;
var currentPersonalInventory = [];

window.onload = function() {
    giveItem('combat_pistol', 1)
    setTotalWeight();
    console.log("(0.1)".replace("(", "").replace(")", ""))
}

function allowDrop(ev) {
    ev.preventDefault();
}

function drop(ev) {
    ev.preventDefault();
    let data = ev.dataTransfer.getData("text");
    let moreThanMaxWeight = false;
    let itemQuantity = (isNaN(parseFloat(document.getElementById('quantity').value))) ?  0 : parseFloat(document.getElementById('quantity').value);
    let targetInventory = ev.target.parentNode.id;
    let sourceInventory = document.getElementById(data).parentNode.id;

    if(ev.target.id == 'use') {
        useItem(data)
    }

    if (ev.target.parentNode.id == "externalInventory") { // check if total weight will be more than the max weight
        if (!(document.getElementById(data).parentNode.id == "externalInventory")) {
            let externalTotalWeight = parseFloat(document.getElementById('externalTotalWeight').innerText.split(" ")[1]);
            let externalMaxWeight = parseFloat(document.getElementById('externalTotalWeight').innerText.split(" ")[3]);
            let itemWeight;

            if(itemQuantity != 0) {
                let itemName = document.getElementById(data).getElementsByClassName('itemtext')[0].innerText
                let itemIndex = items.map(function(a) { return a.itemName }).indexOf(itemName.toUpperCase());
                itemWeight = parseFloat(document.getElementById('quantity').value) * items[itemIndex].itemWeight;
            } else {
                itemWeight = parseFloat(document.getElementById(data).getElementsByClassName('weightCount')[0].innerText.split(" ")[1].replace("(", "").replace(")", ""));
            }

            if (itemWeight + externalTotalWeight > externalMaxWeight) {
                moreThanMaxWeight = true;
            }

        }
    } else if(ev.target.parentNode.id == "personalInventory") {
        if (!(document.getElementById(data).parentNode.id == "personalInventory")) {
            let personalTotalWeight = parseFloat(document.getElementById('personalTotalWeight').innerText.split(" ")[1]);
            let personalMaxWeight = parseFloat(document.getElementById('personalTotalWeight').innerText.split(" ")[3]);
            let itemWeight;

            if(itemQuantity != 0) {
                let itemName = document.getElementById(data).getElementsByClassName('itemtext')[0].innerText
                let itemIndex = items.map(function(a) { return a.itemName }).indexOf(itemName.toUpperCase());
                itemWeight = parseFloat(document.getElementById('quantity').value) * items[itemIndex].itemWeight
            } else {
                itemWeight = parseFloat(document.getElementById(data).getElementsByClassName('weightCount')[0].innerText.split(" ")[1].replace("(", "").replace(")", ""));
            }

            if (itemWeight + personalTotalWeight > personalMaxWeight) {
                moreThanMaxWeight = true;
            }
        }
    }

    if(!(ev.target.id == document.getElementById(data).id) && moreThanMaxWeight == false) {
        if (ev.target.className == 'inventorybox' && !(ev.target.getElementsByClassName('itemtext')[0].innerText == document.getElementById(data).getElementsByClassName('itemtext')[0].innerText)
            && (itemQuantity == 0 || parseFloat(document.getElementById(data).getElementsByClassName('weightCount')[0].innerText.split(" ")[0]) - parseFloat(document.getElementById('quantity').value) == 0)) {

            let element = document.getElementById(data).getElementsByTagName('div')[2]
            let children = document.getElementById(data).childNodes

            if (document.getElementById(data).getElementsByTagName('div')[2] != undefined || ev.target.getElementsByTagName('div')[2] != undefined) {
                if (!(document.getElementById(data).getElementsByTagName('div')[2] != undefined && ev.target.getElementsByTagName('div')[2] != undefined)) {
                    if (element != undefined) {
                        ev.target.appendChild(document.getElementById(data).childNodes[Array.prototype.indexOf.call(children, element)])
                    } else {
                        document.getElementById(data).appendChild(ev.target.childNodes[Array.prototype.indexOf.call(ev.target.childNodes, ev.target.getElementsByTagName('div')[2])])
                    }
                } else {
                    ev.target.appendChild(document.getElementById(data).childNodes[Array.prototype.indexOf.call(children, element)])
                    document.getElementById(data).appendChild(ev.target.childNodes[Array.prototype.indexOf.call(ev.target.childNodes, ev.target.getElementsByTagName('div')[2])])
                }
            }

            var tempDiv = document.createElement("div");

            if (document.getElementById(data).parentNode.id == 'personalInventory') {
                document.querySelectorAll('div.inventory#personalInventory')[0].insertBefore(tempDiv, document.getElementById(data));
                ev.target.parentNode.insertBefore(document.getElementById(data), ev.target);
                document.querySelectorAll('div.inventory#personalInventory')[0].insertBefore(ev.target, tempDiv);
            } else {
                document.querySelectorAll('div.inventory#externalInventory')[0].insertBefore(tempDiv, document.getElementById(data));
                ev.target.parentNode.insertBefore(document.getElementById(data), ev.target);
                document.querySelectorAll('div.inventory#externalInventory')[0].insertBefore(ev.target, tempDiv);
            }

            ev.target.parentNode.removeChild(tempDiv);

            for (let i = 0; i < document.getElementById('personalInventory').querySelectorAll('div.inventorybox').length; i++) {
                let slot = i + 1
                ///console.log('Slot ' + slot + ": " + document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.weightCount')[0].innerText.split(" ")[0] + "x " + document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.itemtext')[0].innerText)
            }

            for (let i = 0; i < document.getElementById('externalInventory').querySelectorAll('div.inventorybox').length; i++) {
                let slot = i + 1
                //console.log('Slot ' + slot + ": " + document.getElementById('externalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.weightCount')[0].innerText.split(" ")[0] + "x " + document.getElementById('externalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.itemtext')[0].innerText)
            }

        } else if (ev.target.className == 'inventorybox') {

            let icon = document.getElementById(data).style.backgroundImage;
            let itemName = document.getElementById(data).getElementsByClassName('itemtext')[0].innerText;
            let count = parseFloat(document.getElementById(data).getElementsByClassName('weightCount')[0].innerText.split(" ")[0]);
            let itemIndex = items.map(function (a) { return a.itemName }).indexOf(itemName);
            let itemWeight = items[itemIndex].itemWeight;
            let targetItemWeight = parseFloat(ev.target.getElementsByClassName('weightCount')[0].innerText.split(" ")[0])
            let quantity = null;

            if (document.getElementById('quantity').value > 0) {
                quantity = parseFloat(document.getElementById('quantity').value);
            } else {
                quantity = parseFloat(document.getElementById(data).getElementsByClassName('weightCount')[0].innerText.split(" ")[0]);
            }

            if (ev.target.getElementsByClassName('itemtext')[0].innerText == itemName && items[itemIndex].stackable == true && !(quantity > count)) {
                ev.target.getElementsByClassName('itemtext')[0].innerText = itemName;
                ev.target.getElementsByClassName('weightCount')[0].innerHTML = (quantity + targetItemWeight) + ' (' + ((quantity + targetItemWeight) * itemWeight).toFixed(1) + ')';

                if (!(quantity == 0 || quantity == count)) {
                    document.getElementById(data).getElementsByClassName('weightCount')[0].innerText = (count - quantity) + ' (' + ((count - quantity) * itemWeight).toFixed(1) + ')';
                } else {
                    document.getElementById(data).style.backgroundImage = 'none';
                    document.getElementById(data).getElementsByClassName('weightCount')[0].innerText = "";
                    document.getElementById(data).getElementsByClassName('itemtext')[0].innerText = "";
                }
            } else if (!(quantity > count) && items[itemIndex].stackable == true) {
                ev.target.style.backgroundImage = icon;
                ev.target.getElementsByClassName('itemtext')[0].innerText = itemName;
                ev.target.getElementsByClassName('weightCount')[0].innerHTML = quantity + ' (' + (quantity * itemWeight).toFixed(1) + ')';
                document.getElementById(data).getElementsByClassName('weightCount')[0].innerText = (count - quantity) + ' (' + ((count - quantity) * itemWeight).toFixed(1) + ')';
            }

        }

        if (sourceInventory == "personalInventory" && targetInventory == "externalInventory") {
            let empty = true;
            for (let i = 0; i < document.getElementById('externalInventory').querySelectorAll('div.inventorybox').length; i++) {
                let itemName = document.getElementById('externalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll("div.itemtext")[0].innerText;
                if (itemName != "" && itemName != document.getElementById(data).querySelectorAll("div.itemtext")[0].innerText) {
                    empty = false;
                    break;
                }
            }
            if (empty == true && isInGroundStash == false) { 
                let contents = [];
                for(let i = 0; i < registerExternalInventory().length; i++) { // convert the array to string form
                    if(registerExternalInventory()[i] != undefined) {
                        contents.push(registerExternalInventory()[i].itemName.replace(" ", "_") + " " + registerExternalInventory()[i].itemCount)
                    } else contents.push("");
                }
                isInGroundStash = true;
                currentGroundStashID = createID(15)
                $.post("http://vd-inventory/dropItem", JSON.stringify({
                    contents: contents.toString(),
                    id: currentGroundStashID
                })); 
            }
        }
        
    }
    setTotalWeight()
    ev.dataTransfer.clearData();
}

function dragStart(ev) {
    if(ev.target.childNodes[0].innerHTML != "") {
        ev.dataTransfer.setData("text/plain", ev.target.id);

        let tempBox = document.createElement('div');
        let itemtext = document.createElement('div');
        itemtext.className = "itemtext";
        itemtext.innerText = ev.target.getElementsByClassName('itemtext')[0].innerText;
        tempBox.className = "inventorybox";
        tempBox.setAttribute('id', 'tempBox')
        tempBox.appendChild(itemtext);

        tempBox.style.backgroundImage = ev.target.style.backgroundImage;
        tempBox.style.transform = 'translateY('+(ev.clientY-100)+'px)';
        tempBox.style.transform += 'translateX('+(ev.clientX-900)+'px)';  
        tempBox.style.position = "absolute";
        tempBox.style.width = "135px";
        tempBox.style.height = "190px";
        tempBox.style.pointerEvents = "none";

        document.querySelectorAll('div.inventoryBody')[0].appendChild(tempBox);

        document.addEventListener('drag', function(ev) {
            ev.target.focus()
            if(document.getElementById('tempBox') != null) {
                document.getElementById('tempBox').style.transform = 'translateY('+(ev.clientY-100)+'px)';
                document.getElementById('tempBox').style.transform += 'translateX('+(ev.clientX-900)+'px)';  
            }
        });

        document.addEventListener('dragend', function(ev) {
            if(document.getElementById('tempBox') != null) {
                document.querySelectorAll('div.inventoryBody')[0].removeChild(document.getElementById('tempBox'))
            }
        });
    } else {
        ev.preventDefault();
    }

}

function showDescription(ev) {
    if (ev.target.querySelectorAll('div.itemtext')[0] != undefined) {
        if (ev.target.querySelectorAll('div.itemtext')[0].innerText != "") {
            document.getElementById('description').style.display = "block";
        }
    }
}

function hideDescription(ev) {
    document.getElementById('description').style.display = "none";
}

function closeInv(e) {
    if(e.key == "Tab" || e.key == "Escape") { 
        document.querySelectorAll('div.inventoryBody')[0].style.display = "none"; 

        registerPersonalInventory()

        let contents = [];
        for(let i = 0; i < registerExternalInventory().length; i++) { // convert the array to string form
            if(registerExternalInventory()[i] != undefined) {
                contents.push(registerExternalInventory()[i].itemName.replace(" ", "_") + " " + registerExternalInventory()[i].itemCount)
            } else contents.push("");
        }

        $.post("http://vd-inventory/closeInv", JSON.stringify({
            stashID: currentGroundStashID,
            contents: contents.toString()
        }))
        currentGroundStashID = 0
        isInGroundStash = false

        removeExternalInventory();
        removePersonalInventory();
    }
}

function createExternalInventory(boxes, contents) {
    if(document.getElementById('externalInventory').querySelectorAll('div.inventorybox')[0] != undefined) {
        removeExternalInventory()
    }
    for(let i = 0; i < boxes; i++) {
        let box = document.createElement('div');
        let itemtext = document.createElement('div');
        let weightCount = document.createElement('div')
        let slot = i + 1

        if(contents == undefined) {
            itemtext.className = "itemtext";
            itemtext.innerText = "";
            weightCount.className = "weightCount"
            weightCount.innerText = ""
        } else {
            let itemName = contents[i].split(" ")[0].replace("_", " ")
            if(itemName != "") {
                let itemCount = contents[i].split(" ")[1]
                let itemIndex = items.map(function(a) { return a.itemName }).indexOf(itemName);
                box.style.backgroundImage = "url(" + items[itemIndex].icon + ")"
                itemtext.className = "itemtext";
                itemtext.innerText = itemName;
                weightCount.className = "weightCount"
                weightCount.innerText = itemCount + " (" + (itemCount * items[itemIndex].itemWeight).toFixed(1) + ")" 
            } else {
                itemtext.className = "itemtext";
                itemtext.innerText = "";
                weightCount.className = "weightCount"
                weightCount.innerText = ""
            }
        }
           
        box.className = "inventorybox";
        box.setAttribute('id', 'e' + slot);
        box.setAttribute('draggable', 'true');
        box.setAttribute('ondragover', 'allowDrop(event)');
        box.setAttribute('ondrop', 'drop(event)');
        box.setAttribute('ondragstart', 'dragStart(event)');
        box.setAttribute('onmouseover', 'showDescription(event)');
        box.setAttribute('onmouseout', 'hideDescription(event)');

        box.appendChild(itemtext);
        box.appendChild(weightCount);
        document.querySelectorAll('div#externalInventory')[0].appendChild(box);
    }
}

function createPersonalInventory() {
    if(document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[0] != undefined) {
        removePersonalInventory();
    }
    for(let i = 0; i < 41; i++) {
        let box = document.createElement('div');
        let itemtext = document.createElement('div');
        let weightCount = document.createElement('div')
        let slot = i + 1

        if(currentPersonalInventory == [] || currentPersonalInventory[i] == undefined) {
            console.log('test')
            itemtext.className = "itemtext";
            itemtext.innerText = "";
            weightCount.className = "weightCount"
            weightCount.innerText = ""
        } else {
            let itemName = currentPersonalInventory[i].split(" ")[0].replace("_", " ")
            if(itemName != "") {
                let itemCount = currentPersonalInventory[i].split(" ")[1]
                let itemIndex = items.map(function(a) { return a.itemName }).indexOf(itemName);

                box.style.backgroundImage = "url(" + items[itemIndex].icon + ")"
                itemtext.className = "itemtext";
                itemtext.innerText = itemName;
                weightCount.className = "weightCount"
                weightCount.innerText = itemCount + " (" + (itemCount * items[itemIndex].itemWeight).toFixed(1) + ")" 
            } else {
                itemtext.className = "itemtext";
                itemtext.innerText = "";
                weightCount.className = "weightCount"
                weightCount.innerText = ""
            }
        }


        box.className = "inventorybox";
        box.setAttribute('id', 'p' + slot);
        box.setAttribute('draggable', 'true');
        box.setAttribute('ondragover', 'allowDrop(event)');
        box.setAttribute('ondrop', 'drop(event)');
        box.setAttribute('ondragstart', 'dragStart(event)');
        box.setAttribute('onmouseover', 'showDescription(event)');
        box.setAttribute('onmouseout', 'hideDescription(event)');
        box.appendChild(itemtext);
        box.appendChild(weightCount);

        if(i < 5 || i == 40) {
            let quickSlot = document.createElement('div');
            quickSlot.className = "quickSlot";
            if(i == 40) { quickSlot.setAttribute('id', 6); } else quickSlot.setAttribute('id', slot); 
            if(i == 40) { quickSlot.innerText = 6; } else quickSlot.innerText = slot;
            box.appendChild(quickSlot)
        }
        document.querySelectorAll('div#personalInventory')[0].appendChild(box);
    }
}

function useItem(itemData) {
    let itemName = document.getElementById(itemData).getElementsByClassName('itemtext')[0].innerText;
    let itemQuantity = parseFloat(document.getElementById(itemData).getElementsByClassName('weightCount')[0].innerText.split(" ")[0])
    let itemWeight = parseFloat(document.getElementById(itemData).getElementsByClassName('weightCount')[0].innerText.split(" ")[1].replace("(", "").replace(")", ""))
    let itemIndex = items.map(function(a) { return a.itemName }).indexOf(itemName);

    if(items[itemIndex].usable == true) {
        if(items[itemIndex].consumable == true) {
            document.getElementById(itemData).getElementsByClassName('weightCount')[0].innerText = (itemQuantity - 1) + " (" + (itemWeight - items[itemIndex].itemWeight).toFixed(1) + ")"
        }
        $.post("http://vd-inventory/" + items[itemIndex].callback, JSON.stringify({
            itemName: document.getElementById(itemData).getElementsByClassName('itemtext')[0].innerText.split(" ")
        }))
    }
}

function setTotalWeight() {
    let personalTotalWeight = 0.0;
    let externalTotalWeight = 0.0;
    for (let i = 0; i < document.getElementById('personalInventory').querySelectorAll('div.inventorybox').length; i++) {
        let itemWeightCount = document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.weightCount')[0].innerText;
        let itemName = document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.itemtext')[0].innerText;
        if(itemWeightCount != "") {
            let itemCount = parseFloat(itemWeightCount.split(" ")[0])
            let itemIndex = items.map(function(a) { return a.itemName }).indexOf(itemName.toUpperCase());
            let itemWeight = items[itemIndex].itemWeight;
            let totalSlotWeight = parseFloat(itemCount * itemWeight);
            personalTotalWeight += totalSlotWeight;
        }
    }

    for (let i = 0; i < document.getElementById('externalInventory').querySelectorAll('div.inventorybox').length; i++) {
        let itemWeightCount = document.getElementById('externalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.weightCount')[0].innerText;
        let itemName = document.getElementById('externalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.itemtext')[0].innerText;
        if(itemWeightCount != "") {
            let itemCount = parseFloat(itemWeightCount.split(" ")[0])
            let itemIndex = items.map(function(a) { return a.itemName }).indexOf(itemName.toUpperCase());
            let itemWeight = items[itemIndex].itemWeight;
            let totalSlotWeight = parseFloat(itemCount * itemWeight);
            externalTotalWeight += totalSlotWeight;
        }
    }

    document.getElementById('personalTotalWeight').innerText = "Weight: " + personalTotalWeight.toFixed(1) + " / 120.0"
    document.getElementById('externalTotalWeight').innerText = "Weight: " + externalTotalWeight.toFixed(1) + " / 120.0"
}

function registerPersonalInventory() {
    currentPersonalInventory = []

    let currentInventory = [];
    for (let i = 0; i < document.getElementById('personalInventory').querySelectorAll('div.inventorybox').length; i++) {
        console.log('test')
        let itemInfo = {itemName: "", itemCount: ""}
        itemInfo.itemName =  document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.itemtext')[0].innerText
        itemInfo.itemCount = document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.weightCount')[0].innerText.split(" ")[0]
        currentInventory.push(itemInfo)
    }

    for(let i = 0; i < currentInventory.length; i++) {
        if(currentInventory[i] != undefined) {
            console.log(i)
            currentPersonalInventory.push(currentInventory[i].itemName.replace(" ", "_") + " " + currentInventory[i].itemCount)
        } else currentPersonalInventory.push("");
    }
    console.log(currentPersonalInventory)
}

function registerExternalInventory() {
    let currentInventory = [];
    for (let i = 0; i < document.getElementById('externalInventory').querySelectorAll('div.inventorybox').length; i++) {
        let itemInfo = {itemName: "", itemCount: ""}
        itemInfo.itemName = document.getElementById('externalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.itemtext')[0].innerText
        itemInfo.itemCount = document.getElementById('externalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.weightCount')[0].innerText.split(" ")[0]
        currentInventory.push(itemInfo)
    }
    return currentInventory;
}

function removeExternalInventory() {
    let inventoryLength = document.getElementById('externalInventory').querySelectorAll('div.inventorybox').length
    for (let i = 0; i < inventoryLength; i++) {
        document.getElementById('externalInventory').removeChild(document.getElementById('externalInventory').querySelectorAll('div.inventorybox')[0])
    }
}

function removePersonalInventory() {
    let inventoryLength = document.getElementById('personalInventory').querySelectorAll('div.inventorybox').length
    for (let i = 0; i < inventoryLength; i++) {
        document.getElementById('personalInventory').removeChild(document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[0])
    }
}

function giveItem(itemName, quantity) {
    if (itemName.indexOf('_') > -1) {
        itemName = itemName.split('_')[0] + " " + itemName.split('_')[1]
    }

    let personalTotalWeight = parseFloat(document.getElementById('personalTotalWeight').innerText.split(" ")[1]);
    let personalMaxWeight = parseFloat(document.getElementById('personalTotalWeight').innerText.split(" ")[3]);
    let itemIndex = items.map(function (a) { return a.itemName }).indexOf(itemName.toUpperCase());
    
    if(items[itemIndex] != undefined) {   
        let itemWeight = quantity * items[itemIndex].itemWeight;

        let startingSlot = 0
        let started = false;

        if (!(itemWeight + personalTotalWeight > personalMaxWeight)) {
            if (quantity > 0) {
                createPersonalInventory()
                for (let i = 0; i < document.getElementById('personalInventory').querySelectorAll('div.inventorybox').length; i++) {
                    let itemText = document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.itemtext')[0].innerText;
                    if (itemText == "") {
                        if (started == false) {
                            started = true;
                            startingSlot = i;
                        }

                        let item = document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[i]
                        item.getElementsByClassName('itemtext')[0].innerHTML = items[itemIndex].itemName;

                        if (items[itemIndex].stackable == true) {
                            item.getElementsByClassName('weightCount')[0].innerHTML = quantity + " (" + (quantity * items[itemIndex].itemWeight).toFixed(1) + ")"
                        } else {
                            item.getElementsByClassName('weightCount')[0].innerHTML = 1 + " (" + items[itemIndex].itemWeight + ")"
                        }

                        item.style.backgroundImage = "url(" + items[itemIndex].icon + ")";
                        if (items[itemIndex].stackable == true) {
                            break;
                        } else if (i == (quantity + startingSlot) - 1) {
                            i = 0
                            break;
                        }
                    }
                }
                itemFeedback(items[itemIndex].itemName, "GOT " + quantity + "x")
            } else $.post("http://vd-inventory/error", JSON.stringify({
                message: "Please specify an amount"
            }))
        } else $.post("http://vd-inventory/error", JSON.stringify({
            message: "The amount you specified was too large"
        }))
    registerPersonalInventory()
    setTotalWeight();
    removePersonalInventory()
    } else $.post("http://vd-inventory/error", JSON.stringify({
        message: "Item '" + itemName + "' is not a valid item!"
    }))

}

function createID(length) {
    var result           = '';
    var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    var charactersLength = characters.length;
    for (let i = 0; i < length; i++ ) {
       result += characters.charAt(Math.floor(Math.random() * charactersLength));
    }
    return result;
 }

function itemFeedback(itemName, message) {
    let tempBox = document.createElement('div');
    let itemtext = document.createElement('div');
    let topLeft = document.createElement('div');

    let itemIndex = items.map(function (a) { return a.itemName }).indexOf(itemName.toUpperCase());

    tempBox.className = "inventorybox";
    tempBox.style.backgroundImage = "url(" + items[itemIndex].icon + ")";
    itemtext.className = 'itemtext';
    itemtext.innerText = items[itemIndex].itemName;
    topLeft.className = "quickSlot";
    topLeft.innerText = message;
    tempBox.setAttribute('id', 'quickSlotInfo');
    tempBox.appendChild(itemtext)
    tempBox.appendChild(topLeft)
    document.getElementsByTagName('body')[0].appendChild(tempBox)
}

window.addEventListener('message', function(e) {
    var data = e.data;

    if(data.type == "showInv") {
        if(document.getElementById('quickSlotInfo') != undefined) {
            document.getElementsByTagName('body')[0].removeChild(document.getElementById('quickSlotInfo'))
        }

        createPersonalInventory();

        if (data.inventoryData != "") {
            if(data.inventoryData.occupied == false) {
                console.log(data.inventoryData.contents.split(",").length)
                createExternalInventory(data.inventoryData.contents.split(",").length, data.inventoryData.contents.split(","))
                currentGroundStashID = data.inventoryData.id
                isInGroundStash = true
                console.log(currentGroundStashID)
            }
        } else {
            createExternalInventory(25)
        }
        
        setTotalWeight();
        body = document.querySelectorAll('div.inventoryBody')[0];
        body.style.display = "block";
        body.focus()
    }

    if(data.type == "quickSlot") {
        createPersonalInventory()
        if(document.getElementById('quickSlotInfo') != undefined) {
            document.getElementsByTagName('body')[0].removeChild(document.getElementById('quickSlotInfo'))
        }

        for (let i = 0; i < document.getElementById('personalInventory').querySelectorAll('div.inventorybox').length; i++) {
            let slot = i + 1
            if(slot == data.slot) {
                if(document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.itemtext')[0].innerText != "") {
                    itemFeedback(document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.itemtext')[0].innerText, "USED");
                    useItem(document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[i].id)
                }
            }
        }
        removePersonalInventory()
    }

    if(data.type == "giveItem") {
        giveItem(data.item, data.quantity)
    }
})