var isInGroundStash = false;
var currentGroundStashID = 0;
var currentPersonalInventory = [];
var externalMaxWeight = 120.0
var isInVehicle = false
var isInTrunk = false
var latestUsedItem = null
var isInventoryOpened = false

function startInventory() {
    var lastPickedUpItem = null

    $('.inventorybox').draggable({
        revert: 'valid',

        start: function (ev, ui) {
            let source = $(this)
            if ($(source.children()[0]).html() == "") {
                console.log('test')
                ev.preventDefault()
            }
        },

        helper: function () {
            let source = $(this)
            if ($(source) != undefined) {
                lastPickedUpItem = source
                return $('<div class="inventorybox" id="tempBox"></div>').css({
                    'width': '125px',
                    'height': '160px',
                    'position': 'absolute',
                    'background-image': $(source).css('background-image')
                }).append('<div class="itemtext">' + $(source.children()[0]).html() + '</div>').appendTo($('.inventoryBody'))
            } else {
                return;
            }
        }
    })

    $('.inventorybox').droppable({
        drop: function (ev, ui) {
            let target = $(this);
            let moreThanMaxWeight = calculateWeightOverflow(lastPickedUpItem.attr('id'), target.attr('id'))
            let itemQuantity = (isNaN(parseFloat($('#quantity').val()))) ? 0 : parseFloat($('#quantity').val());
            let itemIndex = items.map(function (a) { return a.itemName.toUpperCase() }).indexOf($(lastPickedUpItem.children()[0]).html().toUpperCase());
            let itemCount = parseFloat($(lastPickedUpItem.children()[1]).html().split(' ')[0])

            let targetDescription = $(target.children()[2]).html()
            let sourceDescription = $(lastPickedUpItem.children()[2]).html()
            let targetWeightCount = $(target.children()[1]).html()
            let sourceWeightCount = $(lastPickedUpItem.children()[1]).html()
            let targetName = $(target.children()[0]).html()
            let sourceName = $(lastPickedUpItem.children()[0]).html()
            let targetBG = $(target).css('background-image')
            let sourceBG = $(lastPickedUpItem).css('background-image')

            if (!moreThanMaxWeight && !(itemQuantity > itemCount)) {
                if ((itemQuantity == 0 || itemQuantity == itemCount) && (targetName != sourceName || items[itemIndex].stackable == false)) {
                    $(lastPickedUpItem.children()[0]).html(targetName)
                    $(lastPickedUpItem.children()[1]).html(targetWeightCount)
                    $(lastPickedUpItem.children()[2]).html(targetDescription)
                    $(lastPickedUpItem).css('background-image', targetBG)
                    
                    $(target.children()[0]).html(sourceName)
                    $(target.children()[1]).html(sourceWeightCount)
                    $(target.children()[2]).html(sourceDescription)
                    $(target).css('background-image', sourceBG)
                } else if($(target.children()[0]).html() == $(lastPickedUpItem.children()[0]).html() || $(target.children()[0]).html() == "") {
                    let newItemCount = parseFloat(itemCount) - itemQuantity

                    if($(target.children()[0]).html() == $(lastPickedUpItem.children()[0]).html()) {
                        if(itemQuantity == 0 || itemQuantity == itemCount) {
                            itemCount += parseFloat($(target.children()[1]).html().split(' ')[0])

                            $(lastPickedUpItem.children()[0]).html("")
                            $(lastPickedUpItem.children()[1]).html("")
                            $(lastPickedUpItem.children()[2]).html("")
                            $(lastPickedUpItem).css('background-image', 'none')

                            $(target.children()[1]).html(itemCount + ' (' + (itemCount * items[itemIndex].itemWeight).toFixed(1) + ')')
                            $(target).css('background-image', sourceBG)
                        } else {
                            itemCount -= itemQuantity
                            $(lastPickedUpItem.children()[1]).html(itemCount + ' (' + (itemCount * items[itemIndex].itemWeight).toFixed(1) + ')')
                            itemCount = itemQuantity + parseFloat($(target.children()[1]).html().split(' ')[0])
                            $(target.children()[1]).html(itemCount + ' (' + (itemCount * items[itemIndex].itemWeight).toFixed(1) + ')')

                            $(target).css('background-image', sourceBG)
                        }
                    } else {
                        $(target.children()[0]).html($(lastPickedUpItem.children()[0]).html())
                        $(target.children()[1]).html(itemQuantity + ' (' + (itemQuantity * items[itemIndex].itemWeight).toFixed(1) + ')')
                        $(target.children()[0]).html($(lastPickedUpItem.children()[2]).html())

                        $(lastPickedUpItem.children()[1]).html(newItemCount + ' (' + (newItemCount * items[itemIndex].itemWeight).toFixed(1) + ')')
                        $(target).css('background-image', sourceBG)
                    }
                }

                if (lastPickedUpItem.parent().attr('id') == 'personalInventory' && target.parent().attr('id') == 'externalInventory') {
                    dropItem(target.attr('id'))
                }

                $('.ui-draggable-dragging').remove();

                setTotalWeight()
            }
        }
    })

    $('#use').droppable({
        drop: function (ev, ui) {
            if(lastPickedUpItem.parent().attr('id') != 'externalInventory') {
                useItem(lastPickedUpItem.attr('id'))
            }
            $('.ui-draggable-dragging').remove()
        }
    })
}

function dropItem(item) {
    let empty = true;
    for (let i = 0; i < document.getElementById('externalInventory').querySelectorAll('div.inventorybox').length; i++) {
        let itemName = document.getElementById('externalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll("div.itemtext")[0].innerText;
        if (itemName != "" && itemName != document.getElementById(item).querySelectorAll("div.itemtext")[0].innerText) {
            empty = false;
            break;
        }
    }
    if (empty == true && isInGroundStash == false) {
        let contents = [];
        for (let i = 0; i < registerExternalInventory().length; i++) { // convert the array to string form
            if (registerExternalInventory()[i] != undefined) {
                contents.push(registerExternalInventory()[i])
            } else contents.push("");
        }
        isInGroundStash = true;

        if (isInVehicle == false && isInTrunk == false) {
            currentGroundStashID = createID(15)
        } else if (isInVehicle == true) {
            currentGroundStashID = document.getElementById('external').innerText.replace("Glovebox-", "GL")
        } else if (isInTrunk == true) {
            currentGroundStashID = document.getElementById('external').innerText.replace("Trunk-", "TR")
        }

        $.post("http://vd-inventory/dropItem", JSON.stringify({
            contents: contents.toString().replace(/},/g, '}|'),
            id: currentGroundStashID
        }));
    }
}

function calculateWeightOverflow(source, trgt) {
    let moreThanMaxWeight = false;
    let itemQuantity = (isNaN(parseFloat(document.getElementById('quantity').value))) ?  0 : parseFloat(document.getElementById('quantity').value);
    let target = document.getElementById(trgt)

    if (target.parentNode.id == "externalInventory") { // check if total weight will be more than the max weight
        if (!(document.getElementById(source).parentNode.id == "externalInventory")) {
            let externalTotalWeight = parseFloat(document.getElementById('externalTotalWeight').innerText.split(" ")[1]);
            let externalMaxWeight = parseFloat(document.getElementById('externalTotalWeight').innerText.split(" ")[3]);
            let itemWeight;

            if(itemQuantity != 0) {
                let itemName = document.getElementById(source).getElementsByClassName('itemtext')[0].innerText
                let itemIndex = items.map(function(a) { return a.itemName.toUpperCase().toUpperCase() }).indexOf(itemName.toUpperCase());
                itemWeight = parseFloat(document.getElementById('quantity').value) * items[itemIndex].itemWeight;
            } else {
                itemWeight = parseFloat(document.getElementById(source).getElementsByClassName('weightCount')[0].innerText.split(" ")[1].replace("(", "").replace(")", ""));
            }

            if (itemWeight + externalTotalWeight > externalMaxWeight) {
                moreThanMaxWeight = true;
            }

        }
    } else if(target.parentNode.id == "personalInventory") {
        if (!(document.getElementById(source).parentNode.id == "personalInventory")) {
            let personalTotalWeight = parseFloat(document.getElementById('personalTotalWeight').innerText.split(" ")[1]);
            let personalMaxWeight = parseFloat(document.getElementById('personalTotalWeight').innerText.split(" ")[3]);
            let itemWeight;

            if(itemQuantity != 0) {
                let itemName = document.getElementById(source).getElementsByClassName('itemtext')[0].innerText
                let itemIndex = items.map(function(a) { return a.itemName.toUpperCase() }).indexOf(itemName.toUpperCase());
                itemWeight = parseFloat(document.getElementById('quantity').value) * items[itemIndex].itemWeight
            } else {
                itemWeight = parseFloat(document.getElementById(source).getElementsByClassName('weightCount')[0].innerText.split(" ")[1].replace("(", "").replace(")", ""));
            }

            if (itemWeight + personalTotalWeight > personalMaxWeight) {
                moreThanMaxWeight = true;
            }
        }
    }

    return moreThanMaxWeight
}

function showDescription(ev) {
    if (ev.target.querySelectorAll('div.itemtext')[0] != undefined) {
        if (ev.target.querySelectorAll('div.itemtext')[0].innerText != "") {
            let itemName = ev.target.querySelectorAll('div.itemtext')[0].innerText.toLowerCase().split(" ")
            let itemIndex = items.map(function(a) { return a.itemName.toUpperCase() }).indexOf(ev.target.querySelectorAll('div.itemtext')[0].innerText);
            document.getElementById('itemName').innerText = ""
            document.getElementById('description').style.display = "block";
            for(let i = 0; i < itemName.length; i++) {
                itemName[i] = itemName[i].capitalize()
                document.getElementById('itemName').innerText += " " + itemName[i]
            }
            document.getElementById('itemInfo').innerHTML = ev.target.getElementsByClassName('itemDescription')[0].innerHTML
        }
    }
}

const capitalize = (s) => {
    if (typeof s !== 'string') return ''
    return s.charAt(0).toUpperCase() + s.slice(1)
  }

function hideDescription(ev) {
    document.getElementById('description').style.display = "none";
}

function closeInv(e) {
    if(e == undefined || e.key == "Tab" || e.which == 27) { 
        document.querySelectorAll('div.inventoryBody')[0].style.display = "none"; 
        isInventoryOpened = false

        registerPersonalInventory()

        let contents = [];
        for(let i = 0; i < registerExternalInventory().length; i++) { // convert the array to string form
            if(registerExternalInventory()[i] != undefined) {
                contents.push(registerExternalInventory()[i])
            } else contents.push("");
        }

        $.post("http://vd-inventory/closeInv", JSON.stringify({
            stashID: currentGroundStashID,
            contents: contents.toString().replace(/},/g, '}|')
        }))
        document.getElementById('external').innerText = "Ground"
        isInVehicle = false
        isInTrunk = false
        externalMaxWeight = 120.0
        currentGroundStashID = 0
        isInGroundStash = false

        removeExternalInventory();
        removePersonalInventory();
    }
}

function createExternalInventory(boxes, contents) {
    console.log(isInventoryOpened)
    if(isInventoryOpened) {
        return;
    }

    if(document.getElementById('externalInventory').querySelectorAll('div.inventorybox')[0] != undefined) {
        removeExternalInventory()
    }

    for(let i = 0; i < boxes; i++) {
        let box = document.createElement('div');
        let itemtext = document.createElement('div');
        let weightCount = document.createElement('div')
        let description = document.createElement('span')
        let slot = i + 1

        weightCount.className = "weightCount"
        itemtext.className = "itemtext";
        description.className = "itemDescription"
        description.style.position = 'absolute'
        description.style.visibility = 'hidden'

        if(contents == undefined) {
            itemtext.innerText = "";
            weightCount.innerText = ""
            description.innerText = "";
        } else {
            let itemInfo = JSON.parse(contents[i])
            let itemName = itemInfo.itemName

            if(itemName != "") {
                let itemCount = itemInfo.itemCount
                let itemIndex = items.map(function(a) { return a.itemName.toUpperCase() }).indexOf(itemName.toUpperCase());
                box.style.backgroundImage = "url(" + items[itemIndex].icon + ")"
                itemtext.innerText = itemName;
                weightCount.innerText = itemCount + " (" + (itemCount * items[itemIndex].itemWeight).toFixed(1) + ")" 
                description.innerHTML = itemInfo.itemDescription
            } else {
                itemtext.innerText = "";
                weightCount.innerText = ""
                description.innerText = ""
            }
        }
           
        box.className = "inventorybox";
        box.setAttribute('id', 'e' + slot);
        box.setAttribute('onmouseover', 'showDescription(event)');
        box.setAttribute('onmouseout', 'hideDescription(event)');

        box.appendChild(itemtext);
        box.appendChild(weightCount);
        box.appendChild(description);

        document.querySelectorAll('div#externalInventory')[0].appendChild(box);
    }

    startInventory()
}

function createPersonalInventory() {
    if(isInventoryOpened) {
        return;
    }

    if(document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[0] != undefined) {
        removePersonalInventory();
    }

    for(let i = 0; i < 41; i++) {
        let box = document.createElement('div');
        let itemtext = document.createElement('div');
        let weightCount = document.createElement('div')
        let description = document.createElement('span')
        let slot = i + 1

        itemtext.className = "itemtext";
        weightCount.className = "weightCount"
        description.className = "itemDescription"
        description.style.position = 'absolute'
        description.style.visibility = 'hidden'

        if(currentPersonalInventory == [] || currentPersonalInventory[i] == undefined) {
            description.innerText = "";
            itemtext.innerText = "";
            weightCount.innerText = "";
        } else {
            let itemInfo = JSON.parse(currentPersonalInventory[i])
            let itemName = itemInfo.itemName

            if(itemName != "") {
                let itemCount = itemInfo.itemCount
                let itemIndex = items.map(function(a) { return a.itemName.toUpperCase() }).indexOf(itemName.toUpperCase());

                box.style.backgroundImage = "url(" + items[itemIndex].icon + ")"
                itemtext.innerText = itemName;
                weightCount.innerText = itemCount + " (" + (itemCount * items[itemIndex].itemWeight).toFixed(1) + ")" 
                description.innerHTML = itemInfo.itemDescription
            } else {
                itemtext.innerText = "";
                weightCount.innerText = ""
                description.innerText = ""
            }
        }


        box.className = "inventorybox";
        box.setAttribute('id', 'p' + slot);
        box.setAttribute('onmouseover', 'showDescription(event)');
        box.setAttribute('onmouseout', 'hideDescription(event)');
        box.appendChild(itemtext);
        box.appendChild(weightCount);
        box.appendChild(description);

        if(i < 5 || i == 40) {
            let quickSlot = document.createElement('div');
            quickSlot.className = "quickSlot";
            if(i == 40) { quickSlot.setAttribute('id', 6); } else quickSlot.setAttribute('id', slot); 
            if(i == 40) { quickSlot.innerText = 6; } else quickSlot.innerText = slot;
            box.appendChild(quickSlot)
        }
        document.querySelectorAll('div#personalInventory')[0].appendChild(box);
    }

    startInventory()
}

function useItem(itemData) {
    closeInv()

    createPersonalInventory()
    let itemName = document.getElementById(itemData).getElementsByClassName('itemtext')[0].innerText;
    let itemIndex = items.map(function(a) { return a.itemName.toUpperCase() }).indexOf(itemName.toUpperCase());

    if(items[itemIndex].usable == true) {
        $.post("http://vd-inventory/" + items[itemIndex].callback, JSON.stringify({
            itemName: document.getElementById(itemData).getElementsByClassName('itemtext')[0].innerText.split(" "),
        }))
    }

    latestUsedItem = itemData

    removePersonalInventory()
}

function consumeItem() {
    if(latestUsedItem != null) {
        createPersonalInventory()
        let itemName = document.getElementById(latestUsedItem).getElementsByClassName('itemtext')[0].innerText;
        let itemIndex = items.map(function (a) { return a.itemName.toUpperCase() }).indexOf(itemName.toUpperCase());
        let itemQuantity = parseFloat(document.getElementById(latestUsedItem).getElementsByClassName('weightCount')[0].innerText.split(" ")[0])
        let itemWeight = parseFloat(document.getElementById(latestUsedItem).getElementsByClassName('weightCount')[0].innerText.split(" ")[1].replace("(", "").replace(")", ""))

        if (items[itemIndex].consumable == true) {
            console.log("CONSUME")
            document.getElementById(latestUsedItem).getElementsByClassName('weightCount')[0].innerText = (itemQuantity - 1) + " (" + (itemWeight - items[itemIndex].itemWeight).toFixed(1) + ")"
            itemFeedback(itemName, 'VERWIJDERD')
        }

        itemQuantity = parseFloat(document.getElementById(latestUsedItem).getElementsByClassName('weightCount')[0].innerText.split(" ")[0])

        if (itemQuantity <= 0) {
            document.getElementById(latestUsedItem).getElementsByClassName('itemtext')[0].innerText = "";
            document.getElementById(latestUsedItem).getElementsByClassName('weightCount')[0].innerText = "";
            document.getElementById(latestUsedItem).style.backgroundImage = "none";
        }

        latestUsedItem = null

        registerPersonalInventory()
        removePersonalInventory()
    }
}

function setTotalWeight() {
    let personalTotalWeight = 0.0;
    let externalTotalWeight = 0.0;
    for (let i = 0; i < document.getElementById('personalInventory').querySelectorAll('div.inventorybox').length; i++) {
        let itemWeightCount = document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.weightCount')[0].innerText;
        let itemName = document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.itemtext')[0].innerText;
        if(itemName != "") {
            let itemCount = parseFloat(itemWeightCount.split(" ")[0])
            let itemIndex = items.map(function(a) { return a.itemName.toUpperCase() }).indexOf(itemName.toUpperCase());
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
            let itemIndex = items.map(function(a) { return a.itemName.toUpperCase() }).indexOf(itemName.toUpperCase());
            let itemWeight = items[itemIndex].itemWeight;
            let totalSlotWeight = parseFloat(itemCount * itemWeight);
            externalTotalWeight += totalSlotWeight;
        }
    }

    document.getElementById('personalTotalWeight').innerText = "Weight: " + personalTotalWeight.toFixed(1) + " / 120.0"
    document.getElementById('externalTotalWeight').innerText = "Weight: " + externalTotalWeight.toFixed(1) + " / " + externalMaxWeight.toFixed(1)
}

function registerPersonalInventory() {
    currentPersonalInventory = []

    let currentInventory = [];
    for (let i = 0; i < document.getElementById('personalInventory').querySelectorAll('div.inventorybox').length; i++) {
        // let itemInfo = {itemName: "", itemCount: ""}
        // itemInfo.itemName =  document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.itemtext')[0].innerText
        // itemInfo.itemCount = document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.weightCount')[0].innerText.split(" ")[0]
        let itemInfo = JSON.stringify({
            itemName: document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.itemtext')[0].innerText,
            itemCount: document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.weightCount')[0].innerText.split(" ")[0],
            itemDescription: document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('span.itemDescription')[0].innerHTML
        })
        currentInventory.push(itemInfo)
    }

    for(let i = 0; i < currentInventory.length; i++) {
        if(currentInventory[i] != undefined) {
            // currentPersonalInventory.push(currentInventory[i].itemName.replace(" ", "_").replace(" ", "_") + " " + currentInventory[i].itemCount)
            currentPersonalInventory.push(currentInventory[i])
        } else currentPersonalInventory.push("");
    }

    $.post("http://vd-inventory/saveInventory", JSON.stringify({
        contents: currentPersonalInventory.toString().replace(/},/g, '}|')
    }))
}

function registerExternalInventory() {
    let currentInventory = [];
    for (let i = 0; i < document.getElementById('externalInventory').querySelectorAll('div.inventorybox').length; i++) {
        // let itemInfo = {itemName: "", itemCount: ""}
        // itemInfo.itemName = document.getElementById('externalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.itemtext')[0].innerText
        // itemInfo.itemCount = document.getElementById('externalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.weightCount')[0].innerText.split(" ")[0]
        let itemInfo = JSON.stringify({
            itemName: document.getElementById('externalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.itemtext')[0].innerText,
            itemCount: document.getElementById('externalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('div.weightCount')[0].innerText.split(" ")[0],
            itemDescription: document.getElementById('externalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll('span.itemDescription')[0].innerHTML
        })

        currentInventory.push(itemInfo)
    }
    return currentInventory;
}

function removeExternalInventory() {
    if(isInventoryOpened) {
        return;
    }

    let inventoryLength = document.getElementById('externalInventory').querySelectorAll('div.inventorybox').length
    for (let i = 0; i < inventoryLength; i++) {
        document.getElementById('externalInventory').removeChild(document.getElementById('externalInventory').querySelectorAll('div.inventorybox')[0])
    }
}

function removePersonalInventory() {
    if(isInventoryOpened) {
        return;
    }

    let inventoryLength = document.getElementById('personalInventory').querySelectorAll('div.inventorybox').length
    for (let i = 0; i < inventoryLength; i++) {
        document.getElementById('personalInventory').removeChild(document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[0])
    }
}

function giveItem(itemName, quantity) {
    itemName = itemName.replace(/_/g, " ")

    let personalTotalWeight = parseFloat(document.getElementById('personalTotalWeight').innerText.split(" ")[1]);
    let personalMaxWeight = parseFloat(document.getElementById('personalTotalWeight').innerText.split(" ")[3]);
    let itemIndex = items.map(function (a) { return a.itemName.toUpperCase() }).indexOf(itemName.toUpperCase());

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

                        item.querySelectorAll('span.itemDescription')[0].innerHTML = items[itemIndex].description;

                        if(items[itemIndex].callback == 'useWeapon') {
                            item.querySelectorAll('span.itemDescription')[0].innerText += '\n Serialnumber: ' + createID(12)
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

function clearInventory() {
    closeInv()

    createPersonalInventory()
    for (let i = 0; i < document.getElementById('personalInventory').querySelectorAll('div.inventorybox').length; i++) {
        document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll("div.itemtext")[0].innerText = ""
        document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[i].querySelectorAll("div.weightCount")[0].innerText = ""
        document.getElementById('personalInventory').querySelectorAll('div.inventorybox')[i].style.backgroundImage = "none";
    }

    registerPersonalInventory()
    removePersonalInventory()
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

    let itemIndex = items.map(function (a) { return a.itemName.toUpperCase() }).indexOf(itemName.toUpperCase());

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
                createExternalInventory(data.inventoryData.contents.split("|").length, data.inventoryData.contents.split("|"))
                currentGroundStashID = data.inventoryData.id
                isInGroundStash = true

                if(data.vehicleData != undefined) {
                    document.getElementById('external').innerText = "Glovebox-" + data.vehicleData;
                    externalMaxWeight = 10.0;
                    isInVehicle = true;
                }

                if(data.vehiclePlate != undefined) {
                    document.getElementById('external').innerText = "Trunk-" + data.vehiclePlate;
                    externalMaxWeight = 60.0;
                    isInTrunk = true;
                }
            }

        } else if(data.vehicleData != undefined) {
            document.getElementById('external').innerText = "Glovebox-" + data.vehicleData;
            externalMaxWeight = 10.0;
            isInVehicle = true;

            createExternalInventory(5);   
        } else if(data.vehiclePlate != undefined) {
            document.getElementById('external').innerText = "Trunk-" + data.vehiclePlate;
            externalMaxWeight = 60.0;
            isInTrunk = true;

            createExternalInventory(15)
        } else {
            createExternalInventory(25)
        }
        
        setTotalWeight();
        body = document.querySelectorAll('div.inventoryBody')[0];
        body.style.display = "block";
        body.focus()

        isInventoryOpened = true
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

    if(data.type == "consumeItem") {
        consumeItem(latestUsedItem)
    }

    if(data.type == "setInventory") {
        currentPersonalInventory = data.contents.split("|")
        createPersonalInventory()
    }

    if(data.type == "registerInventory") {
        registerPersonalInventory();
    }

    if(data.type == "giveItem") {
        giveItem(data.item, data.quantity)
    }

    if(data.type == "clearInventory") {
        clearInventory()
    }

})

//Credits to https://flaviocopes.com/how-to-uppercase-first-letter-javascript/
String.prototype.capitalize = function() {
    return this.charAt(0).toUpperCase() + this.slice(1)
}