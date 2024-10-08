import Decimal from 'decimal.js';

function init() {
  const workItemAdjustmentContainer = document.getElementById('work-items-adjustment-container');
  const hoursField = document.getElementById('nsm_work_item_form_time_spent_1');
  const minutesField = document.getElementById('nsm_work_item_form_time_spent_2');
  const upliftRemovedYesField = document.getElementById('nsm-work-item-form-uplift-yes-field');
  const upliftRemovedNoField = document.getElementById('nsm-work-item-form-uplift-no-field');
  const calculateChangeButton = document.getElementById('calculate_change_button');
  const caseworkerAdjustedValue = document.getElementById('work_item_caseworker_allowed_amount');
  const caseworkerAdjustedUplift = document.getElementById('work_item_uplift_allowed_amount');

  if (workItemAdjustmentContainer && hoursField && minutesField) {
    updateDomElements();
    calculateChangeButton.addEventListener('click', handleTestButtonClick);
  }

  function handleTestButtonClick(event) {
    event.preventDefault();
    updateDomElements();
  }

  function updateDomElements() {
    const totalPrice = calculateAdjustedAmount();
    const providerUpliftValue = getProviderUplift();
    caseworkerAdjustedValue.innerHTML = totalPrice;
    caseworkerAdjustedUplift.innerHTML = `${ checkUpliftRemoved() ? 0 : providerUpliftValue }%`;
  }

  function calculateAdjustedAmount() {
    const chosenWorkTypeRadio = document.querySelector('input[name="nsm_work_item_form[work_type_value]"]:checked');
    const unitPrice = new Decimal(chosenWorkTypeRadio.dataset.value);
    var upliftAmount = getProviderUplift();

    checkMinutesThreshold();

    var minutes = calculateChangeButton?.getAttribute('data-provider-time-spent');

    if(isNaN(hoursField?.value) || isNaN(minutesField?.value)){
      return '--';
    }

    if(hoursField?.value && minutesField?.value){
      minutes = (parseInt(hoursField.value) * 60) + parseInt(minutesField.value);
    }

    if(checkUpliftRemoved()){
      upliftAmount = 0;
    }

    const upliftFactor = new Decimal(upliftAmount).dividedBy(100).plus(1);

    const unrounded = unitPrice.times(minutes).dividedBy(60).times(upliftFactor);
    return (`£${unrounded.toFixed(2)}`);
  }

  function checkUpliftRemoved(){
    if(upliftRemovedYesField?.checked){
      return true;
    }
    else if(upliftRemovedNoField?.checked){
      return false;
    }
    else{
      return false;
    }
  }

  function checkMinutesThreshold(){
    if(minutesField){
      if(parseInt(minutesField.value) >= 60){
        minutesField.value = 59;
      }
    }
  }

  function getProviderUplift(){
    var uplift = calculateChangeButton?.getAttribute('data-uplift-amount');
    return uplift ? uplift : 0;
  }
}

document.addEventListener('DOMContentLoaded', init);
