require 'rails_helper'

RSpec.describe 'View applications', :stub_oauth_token do
  let(:caseworker) { create(:caseworker, first_name: 'Jane', last_name: 'Doe') }
  let(:application) do
    build(
      :prior_authority_application,
      state: 'submitted',
      created_at: '2023-3-2',
      data: build(
        :prior_authority_data,
        laa_reference: 'LAA-1234',
        additional_costs: build_list(
          :additional_cost,
          1,
          unit_type: 'per_item',
          items: 2,
          cost_per_item: '35.0'
        ),
        quotes: [
          build(
            :primary_quote,
            cost_type: 'per_hour',
            period: 180,
            cost_per_hour: '3.50',
            travel_time: nil,
            travel_cost_per_hour: nil,
            document: {
              'file_name' => 'test – with odd-char.pdf',
              'file_path' => '123123123'
            }
          ),
          build(:alternative_quote)
        ]
      )
    )
  end

  before do
    stub_app_store_interactions(application)
    sign_in caseworker
    visit '/'
    click_on 'Accept analytics cookies'
    application.assigned_user_id = caseworker.id
    visit prior_authority_application_path(application)
  end

  context 'when an application is already assigned to me' do
    it 'shows summary details' do
      expect(page).to have_current_path prior_authority_application_path(application)
      expect(page).to have_content('LAA-1234')
      expect(page).to have_content(
        "Requested: £80.50\nService: Pathologist report " \
        "Representation order date: 2 January 2023\nDate received: 2 March 2023"
      )
    end

    it 'shows my name' do
      expect(page).to have_content('Caseworker: Jane Doe')
    end

    it 'shows that it is in progress' do
      expect(page).to have_content('In progress')
    end

    it 'shows application details card' do
      within('.govuk-summary-card', text: 'Application details') do
        expect(page).to have_content "LAA referenceLAA-1234\nUnique file number130324/001\nPrison LawNo"
      end
    end

    it 'shows primary quote card' do
      within('#primary-quote.govuk-summary-card') do
        expect(page).to have_content "Service requiredPathologist report\n" \
                                     "Service detailsABC DEFABC, HIJ, SW1 1AA\n" \
                                     "Quote uploadtest – with odd-char.pdf\n" \
                                     'Existing prior authority grantedYes'
        expect(page).to have_content 'Cost typeAmountRateTotal requested' \
                                     'Service3 hours 0 minutes£3.50£10.50' \
                                     'ABC2 items£35.00£70.00'
      end
    end

    it 'shows reason why card' do
      within('.govuk-summary-card', text: 'Reason for prior authority') do
        expect(page).to have_content 'Supporting documentsNone'
      end
    end

    it 'shows alternative quote card' do
      within('.govuk-summary-card', text: 'Alternative quote 1') do
        expect(page).to have_content "Service detailsABC DEFABC, HIJ, SW1 1AA\n" \
                                     "Quote uploadNone\nAdditional items\nFoo Bar"
        expect(page).to have_content 'Cost typeAlternative quotePrimary quote' \
                                     'Service£10.50£10.50' \
                                     'Travel£300.00£0.00' \
                                     'Additional£100.00£70.00' \
                                     'Total cost£410.50£80.50'
      end
    end

    it 'shows client details card' do
      within('.govuk-summary-card', text: 'Client details') do
        expect(page).to have_content "Client nameJoe Bloggs\nDate of birth1 January 1950"
      end
    end

    it 'shows case details card' do
      within('.govuk-summary-card', text: 'Case details') do
        expect(page).to have_content "Main offenceRobbery\n" \
                                     "Date of representation order2 January 2023\n" \
                                     "Client detainedNo\n" \
                                     'Subject to POCANo'
      end
    end

    it 'shows hearing details card' do
      within('.govuk-summary-card', text: 'Hearing details') do
        expect(page).to have_content "Date of next hearing1 January 2025\n" \
                                     "Likely or actual pleaGuilty\n" \
                                     'Court typeCrown Court (excluding Central Criminal Court)'
      end
    end

    it 'shows case contact card' do
      within('.govuk-summary-card', text: 'Case contact') do
        expect(page).to have_content "Case contactJane Doejane@doe.com\nFirm detailsLegalCo"
      end
    end

    it 'lets me view associated files' do
      click_on 'test – with odd-char.pdf'
      expect(page).to have_current_path(
        %r{
          /123123123\?response-content-disposition=
          attachment%3B%20filename%3D%22test%2520%25E2%2580%2593%2520with%2520odd-char\.pdf
        }x
      )
    end
  end

  context 'when adjustments have been made to the primary quote' do
    let(:application) do
      build(
        :prior_authority_application,
        created_at: '2023-3-2',
        data: build(
          :prior_authority_data,
          laa_reference: 'LAA-1234',
          quotes: [
            build(
              :primary_quote,
              cost_type: 'per_hour',
              period: 210,
              period_original: 240,
              cost_per_hour: '60.00',
              cost_per_hour_original: '70.00',
              travel_time: 90,
              travel_time_original: 120,
              travel_cost_per_hour: '20.00',
              travel_cost_per_hour_original: '30.00',
            ),
            build(
              :alternative_quote,
              cost_type: 'per_hour',
              period: 300,
              cost_per_hour: '80.00',
              travel_time: 120,
              travel_cost_per_hour: '40.00',
              additional_cost_list: 'Stuff to buy',
              additional_cost_total: '500.00',
            ),
            build(
              :alternative_quote,
              cost_type: 'per_hour',
              period: 300,
              cost_per_hour: '500.00',
              travel_time: nil,
              travel_cost_per_hour: nil,
              additional_cost_list: nil,
              additional_cost_total: nil,
            ),
          ],
          additional_costs: [
            build(
              :additional_cost,
              name: 'Mileage',
              unit_type: 'per_item',
              items_original: 100,
              items: 90,
              cost_per_item_original: '3.50',
              cost_per_item: '2.50',
            ),
            build(
              :additional_cost,
              name: 'Waiting time',
              unit_type: 'per_hour',
              period_original: 120,
              period: 90,
              cost_per_hour_original: '40.0',
              cost_per_hour: '35.0',
            ),
          ]
        )
      )
    end

    it 'shows requested values in the primary quote card' do
      within('#primary-quote.govuk-summary-card') do
        within('.govuk-table') do
          expect(page)
            .to have_content('Cost typeAmountRateTotal requested')
            .and have_content('Service4 hours 0 minutes£70.00£280.00')
            .and have_content('Travel2 hours 0 minutes£30.00£60.00')
            .and have_content('Mileage100 items£3.50£350.00')
            .and have_content('Waiting time2 hours 0 minutes£40.00£80.00')
        end
      end
    end

    it 'shows requested values in the alternative quote card' do
      within('.govuk-summary-card', text: 'Alternative quote 1') do
        within('.govuk-table') do
          expect(page)
            .to have_content('Cost typeAlternative quotePrimary quote')
            .and have_content('Service£400.00£280.00')
            .and have_content('Travel£80.00£60.00')
            .and have_content('Additional£500.00£430.00')
            .and have_content('Total cost£980.00£770.00')
        end
      end
    end

    context 'when alternative quotes have no travel or additional costs' do
      it 'shows requested values in the alternative quote card' do
        within('.govuk-summary-card', text: 'Alternative quote 2') do
          within('.govuk-table') do
            expect(page)
              .to have_content('Cost typeAlternative quotePrimary quote')
              .and have_content('Service£2,500.00£280.00')
              .and have_content('Travel£0.00£60.00')
              .and have_content('Additional£0.00£430.00')
              .and have_content('Total cost£2,500.00£770.00')
          end
        end
      end
    end
  end

  context 'when application has been assessed' do
    before do
      application.data['assessment_comment'] = 'Not good use of money'
      application.state = 'rejected'
      application.app_store_updated_at = DateTime.new(2023, 6, 5, 4, 3, 2)
      visit prior_authority_application_path(application)
    end

    it 'shows the rejection comment' do
      expect(page).to have_content 'Not good use of money'
    end

    it 'shows the rejection date' do
      expect(page).to have_content 'Date assessed: 5 June 2023'
    end
  end

  context 'when application has been sent back' do
    before do
      application.data['updates_needed'] = ['further_information']
      application.data['further_information_explanation'] = 'Set the scene a little more'
      application.state = 'sent_back'
      application.app_store_updated_at = DateTime.new(2023, 6, 5, 4, 3, 2)
      visit prior_authority_application_path(application)
    end

    it 'shows the relevant comment' do
      expect(page).to have_content 'Set the scene a little more'
    end

    it 'shows the rejection date' do
      expect(page).to have_content 'Date sent back to provider: 5 June 2023'
    end
  end

  context 'when application has been updated by provider' do
    before do
      application.data['further_information'] = [
        { caseworker_id: caseworker.id,
          information_requested: "Set the scene \na little more",
          information_supplied: "It was a dark \nand stormy night",
          requested_at: DateTime.new(2023, 5, 2, 4, 3, 2),
          documents: [{ file_name: 'example.pdf', file_path: 'some-file-on-amazon' }] },
        { caseworker_id: caseworker.id,
          information_requested: 'Next request',
          information_supplied: 'Next response',
          requested_at: DateTime.new(2023, 5, 3, 4, 3, 2),
          documents: [] }
      ]
      application.data['incorrect_information'] = [
        { caseworker_id: caseworker.id,
          information_requested: 'Correct it now',
          sections_changed: %w[ufn alternative_quote_1],
          requested_at: DateTime.new(2023, 5, 2, 4, 3, 2), },
      ]
      application.app_store_updated_at = DateTime.new(2023, 6, 5, 4, 3, 2)
      application.state = 'provider_updated'
      build(:event, :provider_updated,
            submission: application,
            details: { comment: 'Added more info',
                       corrected_info: true },
            created_at: DateTime.new(2023, 6, 5, 4, 3, 2))
      application.assigned_user_id = nil
      visit prior_authority_application_path(application)
    end

    it 'shows the relevant further information comments and file links' do
      expect(page).to have_content('Set the scene a little more')
        .and have_content('It was a dark and stormy night')
        .and have_content('example.pdf')
    end

    it 'shows the relevant Amendment comments and links' do
      expect(page).to have_content('Correct it now')
        .and have_content('Application details amended')
        .and have_content('Alternative quote 1 amended')
    end

    it 'shows the updated date' do
      expect(page).to have_content 'Further information request 2 May 2023'
      expect(page).to have_content 'Date amended: 5 June 2023'
    end

    it 'shows RFIs in reverse order' do
      expect(page).to have_text(/Next request.+Set the scene/m)
    end
  end
end
