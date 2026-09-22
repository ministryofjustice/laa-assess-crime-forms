require 'rails_helper'

RSpec.describe Users::DirectoryQuery do
  subject(:entries) do
    described_class.new(role_source:, sort_by:, direction:).call
  end

  let(:role_source) { Authorization::RoleSources::Local.new }
  let(:sort_by) { 'role' }
  let(:direction) { :asc }
  let!(:supervisor) { create(:supervisor, first_name: 'Super', last_name: 'Visor') }
  let!(:caseworker) { create(:caseworker, first_name: 'Case', last_name: 'Worker') }

  it 'returns provider-neutral entries with roles from the injected source' do
    entry = entries.find { _1.id == caseworker.id }

    expect(entry.roles.map(&:role_type)).to eq(['caseworker'])
  end

  it 'sorts by the selected role source' do
    expect(entries.map(&:id)).to eq([caseworker.id, supervisor.id])
  end

  context 'with descending direction' do
    let(:direction) { :desc }

    it 'reverses the selected ordering' do
      expect(entries.map(&:id)).to eq([supervisor.id, caseworker.id])
    end
  end
end
