require 'rails_helper'

RSpec.describe Auth::SilasRoleMapper do
  let(:configured_mappings) do
    {
      'Assess Caseworker (All)' => { role_type: 'caseworker', service: 'all' },
      'Assess Caseworker (NSM)' => { role_type: 'caseworker', service: 'nsm' },
      'Assess Caseworker (PA)' => { role_type: 'caseworker', service: 'pa' },
      'Assess Supervisor (All)' => { role_type: 'supervisor', service: 'all' },
      'Assess Viewer (All)' => { role_type: 'viewer', service: 'all' },
      'Assess Viewer (NSM)' => { role_type: 'viewer', service: 'nsm' },
      'Assess Viewer (PA)' => { role_type: 'viewer', service: 'pa' }
    }
  end

  describe '.call' do
    subject(:mapped_roles) { described_class.call(raw_roles) }

    context 'when roles are provided as an array' do
      let(:raw_roles) { ['Assess Caseworker (NSM)', 'Assess Viewer (PA)'] }

      it 'maps SiLAS role values to Assess role attributes' do
        expect(mapped_roles).to contain_exactly(
          { role_type: 'caseworker', service: 'nsm' },
          { role_type: 'viewer', service: 'pa' }
        )
      end
    end

    context 'when roles are provided as a comma-separated string' do
      let(:raw_roles) { 'Assess Supervisor (All), Assess Viewer (NSM)' }

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
      let(:raw_roles) { ['Assess Caseworker (NSM)', 123] }

      it 'raises an unknown role error' do
        expect { mapped_roles }.to raise_error(Auth::SilasRoleMapper::UnknownRole, /must be strings/)
      end
    end

    context 'when an unknown role is provided' do
      let(:raw_roles) { ['Assess Administrator (All)'] }

      it 'raises an unknown role error' do
        expect { mapped_roles }.to raise_error(Auth::SilasRoleMapper::UnknownRole, /Assess Administrator/)
      end
    end

    context 'when the configured mapping is invalid JSON' do
      let(:raw_roles) { ['Assess Caseworker (NSM)'] }

      before do
        allow(ENV).to receive(:fetch).with('SILAS_ROLE_MAPPINGS', '{}').and_return('{invalid')
      end

      it 'raises a configuration error' do
        expect { mapped_roles }.to raise_error(Auth::SilasRoleMapper::InvalidConfiguration)
      end
    end

    context 'when the configured mapping is not an object' do
      let(:raw_roles) { ['Assess Caseworker (NSM)'] }

      before do
        allow(ENV).to receive(:fetch).with('SILAS_ROLE_MAPPINGS', '{}').and_return('[]')
      end

      it 'raises a configuration error' do
        expect { mapped_roles }.to raise_error(Auth::SilasRoleMapper::InvalidConfiguration, /JSON object/)
      end
    end

    context 'when a configured role mapping is not an object' do
      let(:raw_roles) { ['Assess Caseworker (NSM)'] }

      before do
        allow(ENV).to receive(:fetch).with('SILAS_ROLE_MAPPINGS', '{}').and_return(
          '{"Assess Caseworker (NSM)":"caseworker"}'
        )
      end

      it 'raises a configuration error' do
        expect { mapped_roles }.to raise_error(Auth::SilasRoleMapper::InvalidConfiguration, /Assess Caseworker/)
      end
    end

    context 'when a configured role mapping contains an invalid internal role' do
      let(:raw_roles) { ['Assess Caseworker (NSM)'] }

      before do
        allow(ENV).to receive(:fetch).with('SILAS_ROLE_MAPPINGS', '{}').and_return(
          '{"Assess Caseworker (NSM)":{"role_type":"admin","service":"nsm"}}'
        )
      end

      it 'raises a configuration error' do
        expect { mapped_roles }.to raise_error(Auth::SilasRoleMapper::InvalidConfiguration, /Assess Caseworker/)
      end
    end
  end

  describe '.role_mappings' do
    it 'accepts the seven agreed role and service combinations' do
      expect(described_class.role_mappings).to eq(configured_mappings)
    end

    %w[nsm pa].each do |service|
      it "rejects a supervisor mapping scoped to #{service.upcase}" do
        invalid_mapping = {
          "Assess Supervisor (#{service.upcase})" => {
            role_type: 'supervisor',
            service: service
          }
        }
        allow(ENV).to receive(:fetch).with('SILAS_ROLE_MAPPINGS', '{}').and_return(invalid_mapping.to_json)

        expect { described_class.role_mappings }
          .to raise_error(Auth::SilasRoleMapper::InvalidConfiguration, /Assess Supervisor/)
      end
    end
  end

  describe '.claim_values_for' do
    it 'converts all seven agreed local roles into simulated SiLAS claim values' do
      roles = configured_mappings.values.map do |attributes|
        build(:role, role_type: attributes[:role_type], service: attributes[:service])
      end

      expect(described_class.claim_values_for(roles)).to match_array(configured_mappings.keys)
    end

    it 'rejects local roles that have no configured SiLAS claim value' do
      roles = [build(:role, :caseworker, service: 'nsm')]
      allow(described_class).to receive(:role_mappings).and_return({})

      expect { described_class.claim_values_for(roles) }
        .to raise_error(Auth::SilasRoleMapper::UnknownRole, /No SiLAS role mapping/)
    end
  end
end
