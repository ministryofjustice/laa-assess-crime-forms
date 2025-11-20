require 'rails_helper'

RSpec.describe 'Overview', :stub_oauth_token, type: :system do
  let(:user) { create(:caseworker) }
  let(:claim) { build(:claim) }
  let(:search_params) do
    { page: 1,
      sort_by: 'submitted_at',
      sort_direction: 'descending',
      submission_id: claim.id,
      per_page: 20 }
  end

  before do
    stub_app_store_interactions(claim)
    stub_request(:post, 'https://appstore.example.com/v1/payment_requests/searches').with(body: search_params).to_return(
      status: 201,
      body: { metadata: { total_results: 0 },
              raw_data: [] }.to_json
    )
    sign_in user
    claim.assigned_user_id = user.id
  end

  context 'when claim has been submitted' do
    before { visit nsm_claim_claim_details_path(claim) }

    let(:headings) do
      [
        'Claim summary',
        'Defendant details',
        'Case details',
        'Case disposal',
        'Claim justification',
        'Claim details',
        'Hearing details',
        'Other relevant information',
        'Firm details',
        'Equality monitoring'
      ]
    end

    let(:defendant) { claim.data['defendants'].detect { _1[:main] == true } }
    let(:firm) { claim.data['firm_office'] }
    let(:solicitor) { claim.data['solicitor'] }

    it 'shows me the total claimed but not adjusted' do
      expect(page)
        .to have_content('Claimed: £359.76')
        .and have_no_content('Allowed:')
    end

    it 'shows the expected summary headings' do
      headings.each do |heading|
        expect(page)
          .to have_content(heading)
      end
    end

    it 'shows expected fields within Claim summary section' do
      expect(page).to have_content("Unique file number#{claim.data[:ufn]}")
      expect(page).to have_content('Type of claimNon-standard magistrates')
      expect(page).to have_content('Representation order date13 October 2024')
    end

    it 'shows expected fields within Defendant details section' do
      expect(page).to have_content("Defendant 1 (lead)#{defendant[:first_name]} #{defendant[:last_name]}#{defendant[:maat]}")
    end

    it 'shows expected fields within Case details section' do
      expect(page).to have_content('Main offence nameassault')
      expect(page).to have_content('Offence date12 December 2023')
      expect(page).to have_content('Assigned counselNo')
      expect(page).to have_content('Unassigned counselYes')
      expect(page).to have_content('Instructed agentNo')
      expect(page).to have_content("Case remitted from Crown Court to magistrates' courtNo")
    end

    it 'shows expected fields within Case disposal section' do
      expect(page).to have_content('Category 1Guilty plea')
    end

    it 'shows expected fields within Claim justification section' do
      expect(page).to have_content("Why are you claiming a non-standard magistrates' payment?Counsel or agent assigned")
    end

    it 'shows expected fields within Claim details section' do
      expect(page).to have_content("Number of pages of prosecution evidence#{claim.data[:prosecution_evidence]}")
      expect(page).to have_content("Number of pages of defence statements#{claim.data[:defence_statement]}")
      expect(page).to have_content("Number of witnesses#{claim.data[:number_of_witnesses]}")
      expect(page).to have_content('Recorded evidenceNo')
      expect(page).to have_content('Work done before order was grantedNo')
      expect(page).to have_content('Work was done after last hearingNo')
    end

    it 'shows expected fields within Hearing details section' do
      expect(page).to have_content('Date of first hearing12 December 2012')
      expect(page).to have_content("Number of attendances#{claim.data[:number_of_hearing]}")
      expect(page).to have_content("Magistrates' courtyouth_court")
      expect(page).to have_content('Youth courtNo')
      expect(page).to have_content("Hearing outcome#{claim.data[:hearing_outcome]}")
      expect(page).to have_content("Matter type#{claim.data[:matter_type]}")
    end

    it 'shows expected fields within Other relevant information section' do
      expect(page).to have_content('Any other informationNo')
      expect(page).to have_content('Proceedings concluded over 3 months agoNo')
    end

    it 'shows expected fields within Firm details section' do
      expect(page).to have_content("Firm name#{firm[:name]}")
      expect(page).to have_content("Firm office account number#{firm[:account_number]}")
      expect(page).to have_content("Firm address#{firm[:address_line_1]}#{firm[:address_line_2]}#{firm[:town]}#{firm[:postcode]}")
      expect(page).to have_content("Solicitor full name#{solicitor[:first_name]} #{solicitor[:last_name]}")
      expect(page).to have_content("Solicitor reference number#{solicitor[:reference_number]}")
      expect(page).to have_content("Contact full name#{solicitor[:contact_first_name]} #{solicitor[:contact_last_name]}")
      expect(page).to have_content("Contact email address#{solicitor[:contact_email]}")
    end

    it 'shows expected fields within Equality monitoring section' do
      expect(page).to have_content('Equality questionsNo, skip the equality questions')
    end

    context 'when claim has old translation format' do
      let(:claim) { build(:claim, data: build(:nsm_data, :legacy_translations)) }

      it 'does not crash and renders the page' do
        expect(page)
          .to have_content('Counsel or agent assigned')
          .and have_no_content('Allowed:')
      end
    end
  end

  context 'when I have made a change' do
    before do
      visit nsm_claim_disbursements_path(claim)
      click_on 'Accountants'
      fill_in 'Change disbursement cost', with: '0'
      fill_in 'Explain your decision', with: 'Testing'
      click_on 'Save changes'
    end

    it 'shows me the total claimed and total adjusted' do
      expect(page)
        .to have_content('Claimed: £359.76')
        .and have_content('Allowed: £259.76')
    end
  end

  context 'when claim has been assessed as granted' do
    before { visit nsm_claim_claim_details_path(claim) }

    let(:claim) { build(:claim, state: 'granted') }

    it 'shows me the total claimed and total adjusted' do
      expect(page)
        .to have_content('Claimed: £359.76')
        .and have_content('Allowed: £359.76')
    end
  end

  context 'when claim has been assessed as part granted' do
    let(:claim) { build(:claim, state: 'part_grant') }

    before do
      claim.data['assessment_comment'] = 'Part grant reason'
      claim.data['disbursements'][0]['total_cost_without_vat_original'] = 150
      visit nsm_claim_claim_details_path(claim)
    end

    it 'shows me the decision, comment and review adjustments link' do
      expect(page)
        .to have_selector('strong', text: 'Part granted')
        .and have_content('Part grant reason')
        .and have_link('Review adjustments to disbursements')
    end
  end

  context 'when claim has been sent back and expired' do
    let(:claim) { build(:claim, state: 'expired') }

    before do
      claim.data['assessment_comment'] = 'Send back reason'
      claim.data['further_information'] = [
        {
          documents: [],
          requested_at: DateTime.new(2024, 9, 1, 10, 10, 10),
          information_requested: 'Send back reason'
        }
      ]
      visit nsm_claim_claim_details_path(claim)
    end

    it 'shows me the status and comment' do
      expect(page)
        .to have_content('Expired')
        .and have_content('Send back reason')
    end
  end

  context 'further information requested' do
    let(:claim) { build(:claim, state: 'provider_updated') }
    let(:further_information) do
      [
        {
          'documents' => [
            {
              'file_name' => 'Some_Info.pdf',
              'file_path' => '421727bc53d347ea81edd6a00833671d',
              'file_size' => 690_389,
              'file_type' => 'application/pdf',
              'document_type' => 'supporting_document'
            },
            {
              'file_name' => 'Some_Info2.pdf',
              'file_path' => '421727bc53d347ea81edd6a00833671d',
              'file_size' => 690_389,
              'file_type' => 'application/pdf',
              'document_type' => 'supporting_document'
            }
          ],
          'requested_at' => '2024-08-22T09:42:53.151Z',
          'caseworker_id' => user.id,
          'information_supplied' => 'Added some stuff',
          'information_requested' => 'Example information requested by caseworker'
        },
      ]
    end

    before do
      claim.data['further_information'] = further_information
      claim.data['updated_at'] = DateTime.new(2024, 9, 1, 10, 10, 10)
      allow(FeatureFlags).to receive(:nsm_rfi_loop).and_return(
        instance_double(FeatureFlags::EnabledFeature, enabled?: true)
      )
      visit nsm_claim_claim_details_path(claim)
    end

    it 'shows me state, section header and further information link' do
      expect(page)
        .to have_selector('strong', text: 'Provider updated')
        .and have_selector('h2', text: 'Provider updates')
        .and have_link('Further information')
        .and have_link('Some_Info.pdf')
        .and have_link('Some_Info2.pdf')
    end

    it 'lets me download files' do
      click_on('Some_Info.pdf')
      expect(page).to have_current_path(
        %r{/421727bc53d347ea81edd6a00833671d\?response-content-disposition=attachment%3B%20filename%3D%22Some_Info.pdf}
      )
    end
  end
end
