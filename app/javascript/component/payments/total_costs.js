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
  const counselNetField = document.getElementById("counsel_costs_net");
  const counselVatField = document.getElementById("counsel_costs_vat");

  function updateTotal() {
    function parse(field) {
        const d = field?.value?.trim();
        if (!d) return new Decimal(0);
        try {
          if(isNaN(d)){
            return NaN;
          }
          else{
            return new Decimal(d);
          }
        } catch {
          return null;
        }
      }
    const profit       = parse(profitField);
    const disbursement = parse(disbursementField);
    const travel       = parse(travelField);
    const waiting      = parse(waitingField);
    const counselNet = parse(counselNetField);
    const counselVat = parse(counselVatField);

    let sum = 0;
    if (isNaN(profit) || isNaN(disbursement) || isNaN(travel) || isNaN(waiting) || isNaN(counselNet) || isNaN(counselVat)) {
      total.textContent = "—";
    }
    else if(profitField && disbursementField && travelField && waitingField) {
        sum = profit.plus(disbursement).plus(travel).plus(waiting).toFixed(2);
        total.textContent = `£${sum}`;
    }
    else if(counselNetField && counselVatField){
      sum = counselNet.plus(counselVat).toFixed(2);
      total.textContent = `£${sum}`;
    }
    else {
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

document.addEventListener('DOMContentLoaded', (_event) => {
  const paymentsCalculateContainer = document.getElementById('payments-calculate-container');

  if (paymentsCalculateContainer) init()
})
