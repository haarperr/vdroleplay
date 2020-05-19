var selectedSlot = 0

var charInfo = ["", "", "", "", "", ""];

//giving button the impression that it is selected
function onClick(button) {
    var buttons = document.querySelectorAll('button.button');
    document.querySelector('#create').style.display = "none";
    document.querySelector('#play').style.display = "none";
    document.querySelector('#delete').style.display = "none";
    selectedSlot = button;

    for(i = 0; i < buttons.length; i++) {
        buttons[i].style.backgroundColor = "rgba(0, 0, 0, 0.7)";
    }

    document.getElementById(button).style.backgroundColor = "rgb(214, 63, 63)";

    if(document.getElementById(button).firstChild.textContent == "Leeg Karakterslot") {
        document.querySelector('#create').style.display = "block"; 
        document.getElementById("charinfotext").style.display = "none";
        document.getElementById("selectchar").style.display = "block";
    } else { 
        charIndex = selectedSlot
        document.getElementById("charinfotext").style.display = "block";
        document.getElementById("selectchar").style.display = "none";
        document.querySelector('#play').style.display = "block";
        document.querySelector('#delete').style.display = "block";

        document.getElementById('name').innerHTML = "Naam: " + charInfo[charIndex].firstName + " " + charInfo[charIndex].lastName;
        document.getElementById('dateOfBirth').innerHTML = "Geboortedatum " + charInfo[charIndex].birthDate;
        document.getElementById('gender').innerHTML = "Geslacht: " + charInfo[charIndex].gender;
        document.getElementById('nationalityInfo').innerHTML = "Nationaliteit: " + charInfo[charIndex].nationality;
        document.getElementById('job').innerHTML = "Baan: " + charInfo[charIndex].job;
        document.getElementById('cash').innerHTML = "Cash: " + charInfo[charIndex].cashAmount;
        document.getElementById('bank').innerHTML = "Bank: " + charInfo[charIndex].bankAmount;

        document.getElementById('phone').innerHTML = "Telefoonnummer: " + charInfo[charIndex].phoneNumber;
        document.getElementById('account').innerHTML = "Rekeningnummer: " + charInfo[charIndex].accountNumber;
    }  

}

//hiding and showing some stuff
function createChar() {
    document.querySelectorAll("div.createChar")[0].style.display = "block";
    document.querySelectorAll("div.charbuttons")[0].style.display = "none";
    document.querySelectorAll("div.options")[0].style.display = "none";
    document.querySelectorAll("div.charbox")[0].style.display = "none";
}

//showing and hiding some more stuff
function cancelCreateChar() {
    document.querySelectorAll("div.createChar")[0].style.display = "none";
    document.querySelectorAll("div.charbuttons")[0].style.display = "block";
    document.querySelectorAll("div.options")[0].style.display = "block";
    document.querySelectorAll("div.charbox")[0].style.display = "block";
}

function generateCitizenID() {
    var result           = '';
    var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    var charactersLength = characters.length;
    for ( var i = 0; i < 3; i++ ) {
       result += characters.charAt(Math.floor(Math.random() * charactersLength));
    }
    return result;
 }

// Confirm creating a character
function confirmChar() {
    var emptyFields = [];

    var inputfields = document.querySelectorAll('input.input');   
    var genderInput = document.querySelectorAll('select.input')[0];

    var gender = genderInput.options[genderInput.selectedIndex].text
    var firstName = inputfields[0].value
    var lastName = inputfields[1].value
    var dateOfBirth = inputfields[2].value
    var nationality = inputfields[3].value

    var accountNumber =  "NL06VDRP" + Array.from({ length: 10 }, () => Math.floor(Math.random()*10)).join("")
    var phoneNumber = "06" + Array.from({ length: 8 }, () => Math.floor(Math.random()*10)).join("")
    var citizenID = generateCitizenID() + Array.from({ length: 5 }, () => Math.floor(Math.random()*10)).join("")

    for(i = 0; i < inputfields.length; i++) {
        if (inputfields[i].value == "") {
            emptyFields.push('Empty');
            break;
        }
    }

    if(emptyFields.length == 0) {
        $.post("http://vd-multicharacter/confirmChar", JSON.stringify({
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: dateOfBirth,
            nationality: nationality,
            gender: gender,
            accountNumber: accountNumber,
            phoneNumber: phoneNumber,
            citizenID: citizenID,
            charSlot: selectedSlot
        }));
        cancelCreateChar();
        setTimeout(function() { onClick(selectedSlot) }, 1000) 
    } else {
        emptyFields = [];
        $.post("http://vd-multicharacter/error", JSON.stringify({}));
    }
}

function playChar() {
    $.post("http://vd-multicharacter/playChar", JSON.stringify({
        charSlot: selectedSlot
    }));
}

function deleteChar() {
    $.post("http://vd-multicharacter/deleteChar", JSON.stringify({
        charSlot: selectedSlot
    }))
    document.getElementById(selectedSlot).innerHTML = "Leeg Karakterslot";
    setTimeout(function() { onClick(selectedSlot) }, 800) 
}

//eventlistener for activating char menu and doing stuff with it
window.addEventListener('message', function(e) {
    var item = e.data;
    if(item.type == "charUI") {
        if(item.show == true) {
            document.querySelectorAll("body.body")[0].style.display = "block";
        } else {
            document.querySelectorAll("body.body")[0].style.display = "none";
        }
    } else if(item.type == "charInfo") {
        var playerData = item.playerData;
        for( i=0; i < 5; i++) {
            if(playerData[i] != undefined) {
                if(playerData[i].charSlot != null) {
                    // char name + citizenid
                    charInfo.splice(playerData[i].charSlot, 1, playerData[i]);
                    var txt = document.getElementById(playerData[i].charSlot).innerHTML;
                    var charName = txt.replace("Leeg Karakterslot", playerData[i].firstName + " " + playerData[i].lastName);
                    document.getElementById(playerData[i].charSlot).innerHTML = charName;
                    var spans = document.getElementById(playerData[i].charSlot).getElementsByTagName('span');
                    spans[1].innerText = playerData[i].citizenID;
                    spans[1].style.display = 'block';               
                } else console.log('FATAL ERROR: Couldn\'t load character in slot ' + i + '. Please contact administrators')
            }
        }
    }
})