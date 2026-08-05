require 'rails_helper'

RSpec.describe Authorization::RoleSource do
  describe '.for' do
    it 'builds the registered role authority' do
      expect(described_class.for('local')).to be_a(Authorization::RoleSources::Local)
      expect(described_class.for('silas')).to be_a(Authorization::RoleSources::Silas)
    end

    it 'rejects an unknown role authority' do
      expect { described_class.for('unknown') }
        .to raise_error(described_class::UnknownAuthority, /unknown/)
    end
  end

  describe 'database-backed sources' do
    let(:user) do
      create(
        :caseworker,
        silas_user_name: 'silas-user-123',
        silas_roles: [build(:silas_role, :viewer, service: 'nsm')]
      )
    end

    it 'keeps local and external authorities separate' do
      expect(Authorization::RoleSources::Local.new.roles_for(user)).to be_caseworker(:all)
      expect(Authorization::RoleSources::Local.new.roles_for(user)).not_to be_viewer(:nsm)
      expect(Authorization::RoleSources::Silas.new.roles_for(user)).to be_viewer(:nsm)
      expect(Authorization::RoleSources::Silas.new.roles_for(user)).not_to be_caseworker(:all)
    end

    it 'fails closed when a SiLAS role snapshot is stale' do
      user.authentication_identity_for('silas').update!(
        roles_synced_at: (Rails.configuration.x.auth.reauthenticate_in + 1.second).ago
      )

      expect(Authorization::RoleSources::Silas.new.roles_for(user)).to be_empty
    end

    it 'fails closed when a SiLAS identity has no sync timestamp' do
      user.authentication_identity_for('silas').update!(roles_synced_at: nil)

      expect(Authorization::RoleSources::Silas.new.roles_for(user)).to be_empty
    end
  end
end
