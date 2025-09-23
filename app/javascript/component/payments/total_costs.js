import Decimal from 'decimal.js';

function init() {
  const calculateChangeButton = document.getElementById('payments_calculate_change_button');
  const saveButton = document.getElementById('costs_submit_button');

  const total = document.getElementById('total_cost');
  const totalHidden  = document.getElementById('calculated_total_costs');

  if (!calculateChangeButton || !total || !totalHidden) return;

  const profitField       = document.getElementById("profit_costs");
  const disbursementField = document.getElementById("disbursement_costs");
  const travelField       = document.getElementById("travel_costs");
  const waitingField      = document.getElementById("waiting_costs");

  function updateTotal() {
    const profit       = new Decimal(profitField?.value || 0);
    const disbursement = new Decimal(disbursementField?.value || 0);
    const travel       = new Decimal(travelField?.value || 0);
    const waiting      = new Decimal(waitingField?.value || 0);

    const sum = profit.plus(disbursement).plus(travel).plus(waiting).toFixed(2);
    total.textContent = sum;
    totalHidden.value = sum;
  }

  calculateChangeButton.addEventListener('click', (e) => {
    e.preventDefault();
    updateTotal();
  });

  saveButton.addEventListener('click', (e) => {
    e.preventDefault();
    updateTotal();

    // Find and submit the closest form
    const form = saveButton.closest('form');
    if (form) form.submit();
  });
  // Run once on page load
  updateTotal();
}

document.addEventListener('DOMContentLoaded', init);
