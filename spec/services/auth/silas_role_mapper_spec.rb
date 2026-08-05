require 'rails_helper'

RSpec.describe Auth::SilasRoleMapper do
  describe '.call' do
    subject(:mapped_roles) { described_class.call(raw_roles) }

    context 'when roles are provided as an array' do
      let(:raw_roles) { %w[ASSESS_CASEWORKER_NSM ASSESS_VIEWER_PA] }

      it 'maps SiLAS role values to Assess role attributes' do
        expect(mapped_roles).to contain_exactly(
          { role_type: 'caseworker', service: 'nsm' },
          { role_type: 'viewer', service: 'pa' }
        )
      end
    end

    context 'when roles are provided as a comma-separated string' do
      let(:raw_roles) { 'ASSESS_SUPERVISOR_ALL, ASSESS_VIEWER_NSM' }

      it 'normalises and maps each role' do
        expect(mapped_roles).to contain_exactly(
          { role_type: 'supervisor', service: 'all' },
          { role_type: 'viewer', service: 'nsm' }
        )
      end
    end

    context 'when no roles are provided' do
      let(:raw_roles) { [] }

      it 'raises a missing role error' do
        expect { mapped_roles }.to raise_error(Auth::SilasRoleMapper::MissingRoles)
      end
    end

    context 'when the roles claim is not an array or string' do
      let(:raw_roles) { nil }

      it 'raises a missing role error' do
        expect { mapped_roles }.to raise_error(Auth::SilasRoleMapper::MissingRoles)
      end
    end

    context 'when an array contains a non-string role' do
      let(:raw_roles) { ['ASSESS_CASEWORKER_NSM', 123] }

      it 'raises an unknown role error' do
        expect { mapped_roles }.to raise_error(Auth::SilasRoleMapper::UnknownRole, /must be strings/)
      end
    end

    context 'when an unknown role is provided' do
      let(:raw_roles) { ['ASSESS_ADMIN_ALL'] }

      it 'raises an unknown role error' do
        expect { mapped_roles }.to raise_error(Auth::SilasRoleMapper::UnknownRole, /ASSESS_ADMIN_ALL/)
      end
    end

    context 'when the configured mapping is invalid JSON' do
      let(:raw_roles) { ['ASSESS_CASEWORKER_NSM'] }

      before do
        allow(ENV).to receive(:fetch).with('SILAS_ROLE_MAPPINGS', '{}').and_return('{invalid')
      end

      it 'raises a configuration error' do
        expect { mapped_roles }.to raise_error(Auth::SilasRoleMapper::InvalidConfiguration)
      end
    end

    context 'when the configured mapping is not an object' do
      let(:raw_roles) { ['ASSESS_CASEWORKER_NSM'] }

      before do
        allow(ENV).to receive(:fetch).with('SILAS_ROLE_MAPPINGS', '{}').and_return('[]')
      end

      it 'raises a configuration error' do
        expect { mapped_roles }.to raise_error(Auth::SilasRoleMapper::InvalidConfiguration, /JSON object/)
      end
    end

    context 'when a configured role mapping is not an object' do
      let(:raw_roles) { ['ASSESS_CASEWORKER_NSM'] }

      before do
        allow(ENV).to receive(:fetch).with('SILAS_ROLE_MAPPINGS', '{}').and_return(
          '{"ASSESS_CASEWORKER_NSM":"caseworker"}'
        )
      end

      it 'raises a configuration error' do
        expect { mapped_roles }.to raise_error(Auth::SilasRoleMapper::InvalidConfiguration, /ASSESS_CASEWORKER_NSM/)
      end
    end

    context 'when a configured role mapping contains an invalid internal role' do
      let(:raw_roles) { ['ASSESS_CASEWORKER_NSM'] }

      before do
        allow(ENV).to receive(:fetch).with('SILAS_ROLE_MAPPINGS', '{}').and_return(
          '{"ASSESS_CASEWORKER_NSM":{"role_type":"admin","service":"nsm"}}'
        )
      end

      it 'raises a configuration error' do
        expect { mapped_roles }.to raise_error(Auth::SilasRoleMapper::InvalidConfiguration, /ASSESS_CASEWORKER_NSM/)
      end
    end
  end

  describe '.claim_values_for' do
    it 'converts local roles into simulated SiLAS claim values' do
      roles = [build(:role, :caseworker, service: 'nsm')]

      expect(described_class.claim_values_for(roles)).to eq(['ASSESS_CASEWORKER_NSM'])
    end

    it 'rejects local roles that have no configured SiLAS claim value' do
      roles = [build(:role, :caseworker, service: 'nsm')]
      allow(described_class).to receive(:role_mappings).and_return({})

      expect { described_class.claim_values_for(roles) }
        .to raise_error(Auth::SilasRoleMapper::UnknownRole, /No SiLAS role mapping/)
    end
  end
end
