// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "./component/sortable_table"
import "./component/letters_calls_adjustment"
// https://frontend.design-system.service.gov.uk/importing-css-assets-and-javascript/#javascript
import { initAll } from 'govuk-frontend'

initAll()

Turbo.setFormMode("off")
