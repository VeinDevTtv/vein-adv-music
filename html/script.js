window.addEventListener('message', function(event) {
    const data = event.data;
    if (data.action === "openPerformanceUI") {
        document.getElementById("performanceUI").classList.remove("hidden");
        document.getElementById("trackInfo").innerText = "Now Playing: " + data.trackUrl;
    } else if (data.action === "closePerformanceUI") {
        document.getElementById("performanceUI").classList.add("hidden");
    }
});

document.getElementById("btnTicket").addEventListener("click", function() {
    fetch(`https://${GetParentResourceName()}/uiAction`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json; charset=UTF-8"
        },
        body: JSON.stringify({ action: "buyTicket" })
    });
});

document.getElementById("btnContract").addEventListener("click", function() {
    // Example: static contract data – extend this to allow custom input
    fetch(`https://${GetParentResourceName()}/uiAction`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json; charset=UTF-8"
        },
        body: JSON.stringify({ action: "signContract", label: "Top Records", terms: "70/30 split" })
    });
});
