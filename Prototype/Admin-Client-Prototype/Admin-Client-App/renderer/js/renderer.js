const content = document.getElementById("main")

let navOpened = false;

function openNav() {
    if (navOpened) {
        closeNav();
        return;
    }
    document.getElementById("mainSidenav").style.width = "190px";
    content.style.marginLeft = "190px";
    navOpened = true;
}

function closeNav() {

    if (!navOpened) {
        openNav();
        return;
    }
    document.getElementById("mainSidenav").style.width = "0";
    content.style.marginLeft = "0";
    navOpened = false;
}