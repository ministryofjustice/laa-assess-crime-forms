import "./controllers";
import "./component/nsm/letters_calls_adjustment";
import "./component/nsm/work_item_adjustment";
import "./component/nsm/disbursement_adjustment";
import "./component/prior_authority/service_cost_adjustment";
import "./component/prior_authority/travel_cost_adjustment";
import "./component/prior_authority/additional_cost_adjustment";
import "./component/payments/total_costs";
import "./component/date-picker";
import "@hotwired/turbo-rails"
import { convertSelectToAutocomplete } from "laa-crime-forms-common";
// https://frontend.design-system.service.gov.uk/importing-css-assets-and-javascript/#javascript
import { initAll } from "govuk-frontend";

// set turbo to opt-in
// https://turbo.hotwired.dev/handbook/drive#disabling-turbo-drive-on-specific-links-or-forms
initAll();
Turbo.setFormMode("optin");
Turbo.session.drive = false

convertSelectToAutocomplete();

document.querySelectorAll('[data-disable-on-click=true]').forEach(button => {
    button.addEventListener('click', function() {
        // Use setTimeout with 0ms delay to ensure this runs AFTER the
        // original click event completes
        setTimeout(() => {
            this.disabled = true;
        }, 0);
    });
});

document.addEventListener("turbo:render", function () {
    initAll();
    convertSelectToAutocomplete();
})
