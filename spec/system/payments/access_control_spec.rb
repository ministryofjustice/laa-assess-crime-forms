require 'rails_helper'

RSpec.describe 'Payments access control', :stub_oauth_token do
  let(:index_endpoint) { 'https://appstore.example.com/v1/payment_requests/searches' }
  let(:search_params) do
    {
      page: 1,
      per_page: 20,
      sort_by: 'submitted_at',
      sort_direction: 'descending',
    }
  end

  before do
    allow(FeatureFlags).to receive_messages(payments: double(enabled?: true))
    stub_search(index_endpoint, search_params)
  end

  context 'when signed in as a caseworker with NSM service' do
    let(:user) { create(:caseworker, roles: [build(:role, :caseworker, service: 'nsm')]) }

    before { sign_in user }

    it 'can view payment requests and start creating a payment request' do
      visit root_path
      expect(page).to have_link(I18n.t('home.index.payments'))

      visit payments_requests_path
      expect(page).to have_content('Payment requests')
      expect(page).to have_link('Create payment request')

      visit new_payments_request_path
      expect(page).to have_title('Claim type')
    end
  end

  context 'when signed in as a caseworker with all services' do
    let(:user) { create(:caseworker, roles: [build(:role, :caseworker, service: 'all')]) }

    before { sign_in user }

    it 'can view payment requests and start creating a payment request' do
      visit root_path
      expect(page).to have_link('Request a payment')

      visit payments_requests_path
      expect(page).to have_content('Payment requests')
      expect(page).to have_link('Create payment request')

      visit new_payments_request_path
      expect(page).to have_title('Claim type')
    end
  end

  context 'when signed in as a supervisor' do
    let(:user) { create(:supervisor) }

    before { sign_in user }

    it 'can view payment requests and start creating a payment request' do
      visit root_path
      expect(page).to have_link(I18n.t('home.index.payments'))

      visit payments_requests_path
      expect(page).to have_content('Payment requests')
      expect(page).to have_link('Create payment request')

      visit new_payments_request_path
      expect(page).to have_title('Claim type')
    end
  end

  context 'when signed in as a caseworker with PA service only' do
    let(:user) { create(:caseworker, roles: [build(:role, :caseworker, service: 'pa')]) }

    before { sign_in user }

    it 'does not allow access to payments' do
      visit root_path
      expect(page).to have_no_link(I18n.t('home.index.payments'))

      visit payments_requests_path
      expect(page).to have_content(I18n.t('errors.unauthorised'))
      expect(page).to have_current_path(root_path)
    end
  end

  context 'when signed in as a user with mixed roles of caseworker PA and viewer NSM' do
    let(:user) do
      create(
        :caseworker,
        roles: [
          build(:role, :caseworker, service: 'pa'),
          build(:role, :viewer, service: 'nsm')
        ]
      )
    end

    before { sign_in user }

    it 'does not allow access to payments' do
      visit root_path
      expect(page).to have_no_link(I18n.t('home.index.payments'))

      visit payments_requests_path
      expect(page).to have_content(I18n.t('errors.unauthorised'))
      expect(page).to have_current_path(root_path)
    end
  end

  context 'when signed in as a user with mixed roles of caseworker PA and caseworker NSM' do
    let(:user) do
      create(
        :caseworker,
        roles: [
          build(:role, :caseworker, service: 'pa'),
          build(:role, :caseworker, service: 'nsm')
        ]
      )
    end

    before { sign_in user }

    it 'allows access to payments' do
      visit root_path
      expect(page).to have_link(I18n.t('home.index.payments'))

      visit payments_requests_path
      expect(page).to have_content('Payment requests')
      expect(page).to have_link('Create payment request')
    end
  end
end
