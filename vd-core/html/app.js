function notify(text, type) {
    var notification = document.createElement("div");
    notification.className = "notification";
    notification.innerHTML = text;
    if(type != undefined) {
        if(type == 'red') {
            notification.style.backgroundColor = 'rgba(190, 34, 34, 0.8)'
        } else if(type == 'green') {
            notification.style.backgroundColor = 'rgba(34, 190, 42, 0.8)'
        }
    }
    document.body.appendChild(notification);

    setTimeout(function() { document.body.removeChild(notification) }, 11000)
}

window.addEventListener("message", function(event) {
    var item = event.data;

    if(item.type == "notify") {
        notify(item.message, item.color);
    }
});
