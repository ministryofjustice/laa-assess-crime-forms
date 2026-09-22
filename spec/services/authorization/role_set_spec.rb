require 'rails_helper'

RSpec.describe Authorization::RoleSet do
  subject(:role_set) { described_class.new(roles) }

  let(:roles) do
    [
      build(:role, :caseworker, service: 'nsm'),
      build(:role, :viewer, service: 'pa')
    ]
  end

  it 'checks role and service combinations without knowing the provider' do
    expect(role_set).to be_caseworker(:nsm)
    expect(role_set).not_to be_caseworker(:pa)
    expect(role_set).to be_viewer(:pa)
  end

  it 'treats an all-service role as access to each service' do
    roles << build(:role, :supervisor, service: 'all')

    expect(role_set).to be_supervisor(:nsm)
    expect(role_set).to be_supervisor(:pa)
  end

  it 'reports service access' do
    expect(role_set).to be_access(:nsm)
    expect(role_set).to be_access(:pa)
  end
end
