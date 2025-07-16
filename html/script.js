let currentRaceIndex = 1;
let isProcessingWager = false;

window.addEventListener('message', function(event) {
    const data = event.data;
    if (data.action === 'open') {
        currentRaceIndex = data.raceIndex || 1;
        const wagers = data.wagers || [];
        const raceName = data.raceName || 'Time-Trial-Wagers'; // Fallback to default
        const wagerContainer = document.getElementById('wager-container');
        const raceTitle = document.getElementById('race-title');
        if (raceTitle) {
            raceTitle.innerText = `🏁🏆${raceName}🏆🏁`; // Include emojis from original header
        } else {
            console.warn('Element with id "race-title" not found in the DOM');
        }
        wagerContainer.innerHTML = '';
        wagers.forEach(wager => {
            const button = document.createElement('button');
            // Calculate time to beat: maxTime - timeModifier
            const maxTime = data.maxTime || 60; // Fallback to 60 seconds
            const timeToBeat = maxTime - (wager.timeModifier || 0);
            // Format time as "Xs" or "Xm Ys"
            let timeText;
            if (timeToBeat >= 60) {
                const minutes = Math.floor(timeToBeat / 60);
                const seconds = Math.floor(timeToBeat % 60);
                timeText = `${minutes}m ${seconds}s`;
            } else {
                timeText = `${Math.floor(timeToBeat)}s`;
            }
            // Format amount based on payment type
            let amountText;
            if (wager.paymentType === 'cash' || wager.paymentType === 'bank') {
                amountText = wager.amount === 0 ? 'Free' : `$${wager.amount}`;
            } else if (wager.paymentType === 'crypto') {
                amountText = wager.amount === 0 ? 'Free' : `${wager.amount} Qbit`;
            } else {
                amountText = wager.amount === 0 ? 'Free' : `$${wager.amount}`; // Fallback to $
            }
            // Set button text: "name - amount - time to beat"
            button.innerText = `${wager.name.toLowerCase()} - ${amountText} - ${timeText} to beat`;
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