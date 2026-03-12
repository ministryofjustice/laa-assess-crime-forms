require 'rails_helper'

RSpec.describe Payments::Steps::ClaimSearchController, type: :controller do
  let(:request_type) { 'assigned_counsel' }
  let(:fake_session) { instance_double(Decisions::MultiStepFormSession) }

  before do
    allow(fake_session).to receive(:[]).with('request_type').and_return(request_type)
    allow(controller).to receive(:multi_step_form_session).and_return(fake_session)
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

  describe 'GET #edit (ReturnToCya)' do
    before do
      allow(fake_session).to receive(:[]=)
      allow(fake_session).to receive(:answers).and_return({})
    end

    it 'stores return_to in session when present (via store_return_to_from_params)' do
      get :edit, params: { id: SecureRandom.uuid, return_to: 'check_your_answers' }

      expect(fake_session).to have_received(:[]=).with('return_to', 'check_your_answers')
    end
  end
end
