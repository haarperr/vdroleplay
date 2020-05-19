function notify(text) {
    var notification = document.createElement("div");
    notification.className = "notification";

    if(document.getElementById("first") == null) {
        notification.setAttribute("id", "first");
    }

    notification.innerHTML = text;
    document.body.appendChild(notification);

    setTimeout(function() { document.body.removeChild(notification) }, 11000)
}

window.addEventListener("message", function(event) {
    var item = event.data;

    if(item.type == "notify") {
        notify(item.message);
    }
});
