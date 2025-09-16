import Decimal from 'decimal.js';

function init() {
  const calculateChangeButton = document.getElementById('payments_calculate_change_button');
  const total = document.getElementById('total_cost');

  if (!calculateChangeButton || !total) return;

  const profitField       = document.querySelector("input[name$='[profit_costs]']");
  const disbursementField = document.querySelector("input[name$='[disbursement_costs]']");
  const travelField       = document.querySelector("input[name$='[travel_costs]']");
  const waitingField      = document.querySelector("input[name$='[waiting_costs]']");

  function updateTotal() {
    const profit       = new Decimal(profitField?.value || 0);
    const disbursement = new Decimal(disbursementField?.value || 0);
    const travel       = new Decimal(travelField?.value || 0);
    const waiting      = new Decimal(waitingField?.value || 0);

    const sum = profit.plus(disbursement).plus(travel).plus(waiting);
    total.textContent = sum.toFixed(2);
  }

  calculateChangeButton.addEventListener('click', (e) => {
    e.preventDefault();
    updateTotal();
  });

  // Run once on page load
  updateTotal();
}

document.addEventListener('DOMContentLoaded', init);
