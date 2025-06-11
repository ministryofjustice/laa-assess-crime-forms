require 'rails_helper'

RSpec.describe 'Error pages' do
  let(:user) { create(:caseworker) }

  context 'when authenticated' do
    before { sign_in user }

    context 'when crime application is not found' do
      before do
        visit '/claims/123/case_details'
      end

      it 'shows the application not found error page' do
        expect(page).to have_http_status(:not_found)
        expect(page).to have_content 'If you typed the web address, check it is correct'
      end
    end

    context 'when visiting a non existent page' do
      before do
        visit '/not/a/page'
      end

      it 'shows not found error page' do
        expect(page).to have_content 'If the web address is correct or you selected a link or button'
        expect(page).to have_http_status(:not_found)
      end

      it 'uses the simplified errors page layout' do
        expect(page).to have_no_css('.govuk-service-navigation')
      end
    end

    context 'when visiting a forbidden page' do
      before do
        visit users_auth_failure_path
      end

      it 'shows the forbidden page' do
        expect(page).to have_content 'Access to this service is restricted'
        expect(page).to have_http_status(:forbidden)
      end

      it 'uses the simplified errors page layout' do
        expect(page).to have_no_css('.govuk-service-navigation')
      end
    end
  end

  context 'when not authenticated' do
    context 'when visiting a non existent page not on a service path' do
      it 'shows "Page not found"' do
        visit '/._darcs'
        expect(page).to have_content 'Page not found'
        expect(page).to have_http_status :not_found
      end
    end

    context 'when visiting a non existent page' do
      it 'redirects to sign in even if application does not exist' do
        expected_content = 'Page not found'
        visit '/applications/n0tan1d'
        expect(page).to have_content expected_content
      end
    end
  end
end
