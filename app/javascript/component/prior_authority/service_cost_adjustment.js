import CostAdjustment from './cost_adjustment.js'

function init() {
  const fields = [
    document.getElementById('prior_authority_service_cost_form_period_1'),
    document.getElementById('prior_authority_service_cost_form_period_2'),
    document.getElementById('prior-authority-service-cost-form-cost-per-hour-field'),
    document.getElementById('prior-authority-service-cost-form-items-field'),
    document.getElementById('prior-authority-service-cost-form-cost-per-item-field'),
    document.getElementById('calculate_change_button'),
    document.getElementById('adjusted-cost'),
    false
  ]

  const costAdjustment = new CostAdjustment(...fields)

  if (costAdjustment.calculationType() != 'unknown_type') {
    costAdjustment.calculateChangeButton.addEventListener('click', handleTestButtonClick);
  }

  function handleTestButtonClick(event) {
    event.preventDefault();
    costAdjustment.updateDomElements();
  }
}

document.addEventListener('DOMContentLoaded', (_event) => {
  const serviceCostAdjustmentContainer = document.getElementById('service-cost-adjustment-container');

  if (serviceCostAdjustmentContainer) init()
})
