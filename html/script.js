let currentRaceIndex = 1;  // Default to race 1

window.addEventListener('message', function(event) {
    const data = event.data;
    if (data.action === 'open') {
        currentRaceIndex = data.raceIndex || 1;
        showUI();
    } else if (data.action === 'close') {
        hideUI();
    }
});

function hideUI() {
    document.getElementById('main-menu').style.display = 'none';
}

function showUI() {
    document.getElementById('main-menu').style.display = 'block';
}

function closeMenu() {
    fetch('https://mnc-timetrials/close', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).then(res => res.text()).then(data => {
        if (data === 'ok') hideUI();
    });
}

function selectWager(amount) {
    fetch('https://mnc-timetrials/selectWager', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ wager: amount, raceIndex: currentRaceIndex })  // <-- send raceIndex here
    }).then(res => res.text()).then(data => {
        if (data === 'ok') hideUI();
    });
}

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeMenu();
    }
});
