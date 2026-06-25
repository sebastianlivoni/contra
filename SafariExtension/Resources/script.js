document.addEventListener('mouseup', (e) => {
    if (e.button === 3) {
        history.back()
    } else if (e.button === 4) {
        history.forward();
    }
});
