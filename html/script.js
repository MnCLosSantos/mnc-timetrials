let currentRaceIndex = 1;
let isProcessingWager = false;

window.addEventListener('message', function(event) {
    const data = event.data;
    if (data.action === 'open') {
        currentRaceIndex = data.raceIndex || 1;
        const wagers = data.wagers || [];
        const wagerContainer = document.getElementById('wager-container');
        wagerContainer.innerHTML = '';
        wagers.forEach(wager => {
            const button = document.createElement('button');
            button.innerText = wager.amount === 0 ? `${wager.name} - Free` : `${wager.name} - $${wager.amount}`;
            button.className = wager.name.toLowerCase();
            button.onclick = () => selectWager(wager.amount);
            wagerContainer.appendChild(button);
        });
        showUI();
    } else if (data.action === 'close') {
        hideUI();
    }
});

function hideUI() {
    document.getElementById('main-menu').style.display = 'none';
    isProcessingWager = false;
    enableWagerButtons();
}

function showUI() {
    document.getElementById('main-menu').style.display = 'block';
}

function disableWagerButtons() {
    const buttons = document.querySelectorAll('#wager-container button');
    buttons.forEach(button => button.disabled = true);
}

function enableWagerButtons() {
    const buttons = document.querySelectorAll('#wager-container button');
    buttons.forEach(button => button.disabled = false);
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
    if (isProcessingWager) return;
    isProcessingWager = true;
    disableWagerButtons();
    fetch('https://mnc-timetrials/selectWager', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ wager: amount, raceIndex: currentRaceIndex })
    }).then(res => res.text()).then(data => {
        if (data === 'ok') {
            hideUI();
        } else {
            isProcessingWager = false;
            enableWagerButtons();
        }
    });
}

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeMenu();
    }
});