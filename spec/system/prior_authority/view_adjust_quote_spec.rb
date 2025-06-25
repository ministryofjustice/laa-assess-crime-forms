require 'rails_helper'

RSpec.describe 'View Adjust quote tab', :stub_oauth_token do
  before do
    stub_app_store_interactions(application)
    sign_in caseworker
    visit '/'
    click_on 'Accept analytics cookies'

    application.assigned_user_id = caseworker.id

    visit prior_authority_application_path(application)
    click_on 'Adjust quote'
  end

  let(:caseworker) { create(:caseworker) }

  context 'with service, travel and addtional costs' do
    let(:application) do
      build(
        :prior_authority_application,
        state: 'submitted',
        data: build(
          :prior_authority_data,
          laa_reference: 'LAA-1234',
          quotes: [
            build(
              :primary_quote,
              cost_type: 'per_hour',
              item_type: 'item',
              period: 180,
              cost_per_hour: '3.50',
              travel_time: 95,
              travel_cost_per_hour: 10.5,
              travel_cost_reason: 'it was a long way'
            ),
            build(:alternative_quote)
          ],
          additional_costs: [
            build(
              :additional_cost,
              name: 'Mileage',
              description: 'fuel is expensive',
              unit_type: 'per_item',
              items: 110,
              cost_per_item: '3.5'
            ),
            build(
              :additional_cost,
              name: 'Waiting time',
              description: 'delayed interview at police station',
              unit_type: 'per_hour',
              period: 240,
              cost_per_hour: '50.0'
            ),
          ],
        )
      )
    end

    it 'shows the key information card' do
      within('.govuk-summary-card') do
        expect(page)
          .to have_css('.govuk-summary-card__title', text: 'Key information')
          .and have_content('Main offenceRobbery')
          .and have_content('Service provider locationHIJ, SW1 1AA')
      end
    end

    it 'shows the service cost summary' do
      expect(page).to have_css('.govuk-heading-m', text: 'Pathologist report cost')

      within('.govuk-table#service_costs') do
        expect(page)
          .to have_content('Amount3 hours 0 minutes')
          .and have_content('Rate£3.50 per hour')
          .and have_content('Total£10.50')
      end

      expect(page).to have_css('.govuk-button', text: 'Adjust service costs')
    end

    it 'shows the travel cost summary' do
      expect(page).to have_css('.govuk-heading-m', text: 'Travel cost')
      expect(page)
        .to have_css('p', text: 'Reason for travel cost:')
        .and have_css('p', text: 'it was a long way')

      within('.govuk-table#travel_costs') do
        expect(page)
          .to have_content('Amount1 hour 35 minutes')
          .and have_content('Rate£10.50 per hour')
          .and have_content('Total£16.63')
      end

      expect(page).to have_css('.govuk-button', text: 'Adjust travel costs')
    end

    it 'shows the additional cost summaries' do
      expect(page).to have_css('.govuk-heading-m', text: 'Additional cost 1')
      expect(page).to have_css('p', text: 'Cost description: Mileage')
                  .and have_css('p', text: 'fuel is expensive')

      within('.govuk-table#additional_cost_1') do
        expect(page)
          .to have_content('Amount110 items')
          .and have_content('Rate£3.50 per item')
          .and have_content('Total£385.00')
      end

      expect(page).to have_css('p', text: 'Cost description: Waiting time')
                  .and have_css('p', text: 'delayed interview at police station')

      within('.govuk-table#additional_cost_2') do
        expect(page)
          .to have_content('Amount4 hours 0 minutes')
          .and have_content('Rate£50.00 per hour')
          .and have_content('Total£200.00')
      end

      expect(page).to have_css('.govuk-button', text: 'Adjust additional cost', count: 2)
    end

    context 'with a per item service cost' do
      let(:application) do
        build(
          :prior_authority_application,
          state: 'submitted',
          data: build(
            :prior_authority_data,
            laa_reference: 'LAA-1234',
            service_type: 'translation_and_transcription',
            quotes: [
              build(
                :primary_quote,
                cost_type: 'per_item',
                item_type: 'minute',
                cost_item_type: 'minute',
                items: 100,
                cost_per_item: '2.00',
              ),
              build(:alternative_quote)
            ],
            additional_costs: [],
          )
        )
      end

      it 'shows the service cost summary' do
        expect(page).to have_css('.govuk-heading-m', text: 'Translation and transcription cost')

        within('.govuk-table#service_costs') do
          expect(page)
            .to have_content('Amount100 minutes')
            .and have_content('Rate£2.00 per minute')
            .and have_content('Total£200.00')
        end

        expect(page).to have_css('.govuk-button', text: 'Adjust service costs')
      end
    end
  end

  context 'with no travel or addtional costs' do
    let(:application) do
      build(
        :prior_authority_application,
        data: build(
          :prior_authority_data,
          laa_reference: 'LAA-1234',
          quotes: [
            build(
              :primary_quote,
              cost_type: 'per_hour',
              item_type: 'item',
              period: 180,
              cost_per_hour: '3.50',
              travel_time: nil,
              travel_cost_per_hour: nil,
              travel_cost_reason: nil
            ),
            build(:alternative_quote)
          ],
          additional_costs: [],
        )
      )
    end

    it 'does not show the travel costs summary' do
      expect(page).to have_no_content('Travel cost')
        .and have_no_content('Reason for travel cost')
        .and have_no_css('.govuk-table#travel_costs')
    end

    it 'does not show any addtional costs summaries' do
      expect(page).to have_no_content('Additional cost')
        .and have_no_content('Cost description"')
        .and have_no_css('.govuk-table#tadditional_cost_1')
    end
  end
end
