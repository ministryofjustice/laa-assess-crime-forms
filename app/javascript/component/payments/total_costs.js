import Decimal from 'decimal.js';

function init() {
  const calculateChangeButton = document.getElementById('payments_calculate_change_button');
  const saveButton = document.getElementById('costs_submit_button');

  const total = document.getElementById('total_cost');

  if (!calculateChangeButton || !total) return;

  const profitField       = document.getElementById("profit_costs");
  const disbursementField = document.getElementById("disbursement_costs");
  const travelField       = document.getElementById("travel_costs");
  const waitingField      = document.getElementById("waiting_costs");

  function updateTotal() {
    function parse(field) {
        const d = field?.value?.trim();
        if (!d) return new Decimal(0);
        try {
          return new Decimal(d);
        } catch {
          return null;
        }
      }
    const profit       = parse(profitField);
    const disbursement = parse(disbursementField);
    const travel       = parse(travelField);
    const waiting      = parse(waitingField);

    if (profit && disbursement && travel && waiting) {
      const sum = profit.plus(disbursement).plus(travel).plus(waiting).toFixed(2);
      total.textContent = sum;
    } else {
      total.textContent = "—";
    }
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
