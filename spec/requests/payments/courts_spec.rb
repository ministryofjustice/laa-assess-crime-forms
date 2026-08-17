require 'rails_helper'

RSpec.describe 'Payment courts' do
  before do
    allow(FeatureFlags).to receive(:payments).and_return(instance_double(FeatureFlags::EnabledFeature, enabled?: true))
  end

  it 'returns the court list with a 24-hour cache lifetime' do
    get payments_courts_path(format: :json)

    expect(response).to be_successful
    expect(response.parsed_body).to eq(LaaCrimeFormsCommon::Court.all.map(&:as_json))
    expect(response.headers['Cache-Control']).to include('max-age=86400')
  end
end
