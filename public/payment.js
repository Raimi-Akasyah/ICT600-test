// payment.js

document.getElementById('paymentForm').addEventListener('submit', async function(e) {
    e.preventDefault();
    const form = e.target;
    const data = {
        user_id: form.user_id.value,
        card_number: form.card_number.value,
        expiry_date: form.expiry_date.value,
        cvv: form.cvv.value,
        amount: form.amount.value
    };
    const msg = document.getElementById('paymentMessage');
    msg.textContent = '';
    try {
        const res = await fetch('/api/payment', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        const result = await res.json();
        if (res.ok && result.success) {
            msg.style.color = '#0f0';
            msg.textContent = 'Payment successful!';
            setTimeout(() => window.location.href = 'login.html', 1500);
        } else {
            msg.style.color = '#f00';
            msg.textContent = result.message || 'Payment failed.';
        }
    } catch (err) {
        msg.style.color = '#f00';
        msg.textContent = 'Network error.';
    }
});
