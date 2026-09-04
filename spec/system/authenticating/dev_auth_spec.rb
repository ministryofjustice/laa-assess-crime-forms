require 'rails_helper'

RSpec.describe 'Authenticating with the DevAuth strategy' do
  before { user }

  let(:user) { nil }

  describe 'clicking the "Sign in" button' do
    before do
      visit '/'
    end

    it 'shows the dev auth page' do
      expect(page).to have_current_path '/dev_auth'
      expect(page).to have_content 'This is a mock sign in page for use in local development only'
    end

    context 'when the "Not Authorised" user is chosen' do
      before do
        select OmniAuth::Strategies::DevAuth::NO_AUTH_EMAIL
        click_on 'Sign in'
      end

      it 'redirects to the forbidden page' do
        expect(page).to have_content 'Access to this service is restricted'
      end

      it 'shows the forbidden page' do
        expect(page).to have_content 'Access to this service is restricted'
        expect(page).to have_no_css('.govuk-service-navigation')
      end
    end

    context 'when a disabled user is in the system' do
      let(:user) do
        create(:caseworker, first_name: nil, last_name: nil, email: 'Zoe.Doe@example.com', deactivated_at: DateTime.now)
      end

      it 'they cannot sign in' do
        expect(page).not_to have_select('email_field', with_options: [user.email])
      end
    end

    context 'when an unauthenticated user is in the system' do
      let(:user) do
        create(:caseworker, first_name: nil, last_name: nil, email: 'Zoe.Doe@example.com', auth_subject_id: nil)
      end

      before do
        select user.email
        click_on 'Sign in'
      end

      it 'signs in the user' do
        expect(page).to have_content 'Zoe Doe'
        expect(page).to have_content 'Assess a crime form'
      end

      it 'guesses the name from the email' do
        expect(user.reload.display_name).to eq('Zoe Doe')
      end

      it 'creates an Azure AD identity' do
        expect(user.reload.authentication_identity_for('azure_ad')&.subject).to be_present
      end
    end

    context 'when an authorised, authenticated, user is selected' do
      let(:azure_subject) { SecureRandom.uuid }
      let(:user) do
        create(
          :caseworker,
          email: 'Zoe.Doe@example.com',
          first_name: nil,
          last_name: 'Dowe',
          auth_subject_id: azure_subject
        )
      end

      before do
        select user.email
        click_on 'Sign in'
      end

      it 'signs in as the user' do
        expect(page).to have_content 'Zoe Dowe'
        expect(page).to have_content 'Assess a crime form'
      end

      it 'does not change the user\'s name or Azure AD subject' do
        user_after_auth = user.reload
        expect(user_after_auth.display_name).to eq('Zoe Dowe')
        expect(user_after_auth.authentication_identity_for('azure_ad').subject).to eq(azure_subject)
      end
    end

    context 'when SiLAS auth is selected' do
      before do
        allow(Auth::Provider).to receive(:current).and_return(Auth::Provider.fetch('silas'))
        visit '/'
      end

      let(:user) do
        create(
          :caseworker,
          email: 'Sally.Silas@example.com',
          first_name: 'Sally',
          last_name: 'Silas',
          silas_user_name: 'silas-user-123',
          silas_roles: [build(:silas_role, :caseworker, service: 'all')]
        )
      end

      it 'simulates the configured SiLAS identity and role claims' do
        select user.email
        click_on 'Sign in'

        expect(page).to have_content 'Sally Silas'
        expect(user.reload.silas_roles.pluck(:role_type, :service)).to eq([%w[caseworker all]])
      end

      context 'when the user already has cached SiLAS roles' do
        let(:user) do
          create(
            :caseworker,
            email: 'Sally.Silas@example.com',
            first_name: 'Sally',
            last_name: 'Silas',
            silas_user_name: 'silas-user-123',
            roles: [build(:role, :caseworker, service: 'pa')],
            silas_roles: [build(:silas_role, :viewer, service: 'nsm')]
          )
        end

        it 'uses the SiLAS roles for the simulated claims' do
          select user.email
          click_on 'Sign in'

          expect(user.reload.silas_roles.pluck(:role_type, :service)).to eq([%w[viewer nsm]])
        end
      end

      context 'when the selected user has not been given a SiLAS identity' do
        let(:user) { create(:caseworker, email: 'unprovisioned@example.com') }

        it 'fails closed' do
          select user.email
          click_on 'Sign in'

          expect(page).to have_content 'Access to this service is restricted'
        end
      end

      context 'when no matching local user exists' do
        it 'fails closed' do
          select OmniAuth::Strategies::DevAuth::NO_AUTH_EMAIL
          click_on 'Sign in'

          expect(page).to have_content 'Access to this service is restricted'
        end
      end
    end
  end

  context 'when dev_auth is disabled' do
    before { allow(FeatureFlags).to receive(:dev_auth).and_return(double(enabled?: false)) }

    it 'raises an error' do
      visit '/dev_auth'

      expect(page).to have_http_status(:not_found)
    end
  end
end
