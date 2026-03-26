require 'rails_helper'

RSpec.describe Payments::Steps::ClaimSearchController, type: :controller do
  let(:request_type) { 'assigned_counsel' }
  let(:fake_session) { instance_double(Decisions::MultiStepFormSession) }

  before do
    allow(fake_session).to receive(:[]).with('request_type').and_return(request_type)
    allow(fake_session).to receive(:answers).and_return({ 'id' => 'sub-1' })
    allow(fake_session).to receive(:mark_return_to_cya!)
    allow(controller).to receive(:multi_step_form_session).and_return(fake_session)
  end

  describe 'GET #edit' do
    before do
      allow(Payments::Steps::SelectedClaimForm).to receive(:build).and_return(instance_double(Payments::Steps::SelectedClaimForm))
      search_form = instance_double(Payments::Steps::ClaimSearchForm, valid?: false, execute: nil)
      allow(Payments::Steps::ClaimSearchForm).to receive(:new).and_return(search_form)
    end

    it 'marks return to CYA when the query param is present' do
      get :edit, params: { id: 'sub-1', return_to_cya: '1' }

      expect(fake_session).to have_received(:mark_return_to_cya!)
    end

    it 'does not mark return to CYA without the query param' do
      get :edit, params: { id: 'sub-1' }

      expect(fake_session).not_to have_received(:mark_return_to_cya!)
    end
  end

  describe '#page_heading' do
    {
      'assigned_counsel' => 'Search for the non-standard magistrates claim',
      'non_standard_mag_supplemental' => 'Search for the non-standard magistrates claim',
      'non_standard_mag_appeal' => 'Search for the non-standard magistrates claim',
      'non_standard_mag_amendment' => 'Search for the non-standard magistrates claim',
      'assigned_counsel_appeal' => 'Search for the assigned counsel claim',
      'assigned_counsel_amendment' => 'Search for the assigned counsel claim'
    }.each do |type, expected_heading|
      context "when request_type is #{type}" do
        let(:request_type) { type }

        it "returns '#{expected_heading}'" do
          expect(controller.send(:page_heading)).to eq(expected_heading)
        end
      end
    end
  end

  describe '#linked_request_type' do
    let(:request_type) { 'unknown_type' }

    it 'raises for unknown request types' do
      expect { controller.send(:linked_request_type) }
        .to raise_error(StandardError, 'Unknown request type for: unknown_type')
    end
  end
end
