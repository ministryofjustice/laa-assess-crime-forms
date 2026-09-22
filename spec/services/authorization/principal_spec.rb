require 'rails_helper'

RSpec.describe Authorization::Principal do
  subject(:principal) { described_class.new(user:, role_source:) }

  let(:user) { create(:caseworker, roles: [build(:role, :viewer, service: 'pa')]) }
  let(:role_source) { Authorization::RoleSources::Local.new }

  it 'keeps identity and provider-neutral permission predicates together for Pundit' do
    expect(principal.id).to eq(user.id)
    expect(principal).to be_viewer(:pa)
    expect(principal).to be_pa_access
    expect(principal).not_to be_nsm_access
  end
end
