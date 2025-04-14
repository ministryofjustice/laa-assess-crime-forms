require 'rails_helper'

RSpec.describe 'Users', :stub_oauth_token do
  let(:caseworker) { create(:caseworker, first_name: 'John', last_name: 'Everyman', email: 'case@worker.com') }
  let(:supervisor) { create(:supervisor, first_name: 'Ad', last_name: 'Minh', email: 'ad@minh.com') }

  before do
    caseworker.save
    supervisor.save
    sign_in supervisor
    visit users_path
  end

  describe '#index' do
    context 'for non-admins' do
      before do
        sign_in caseworker
        visit users_path
      end

      it 'does not allow access' do
        expect(page).not_to have_content(I18n.t('users.index.page_title'))
      end
    end

    context 'for admins' do
      it 'allows admins' do
        expect(page).to have_content(I18n.t('users.index.page_title'))
      end

      it 'allows sorting by role in both directions' do
        click_on 'Role'

        within 'table' do
          expect(page).to have_content(/John Everyman.*Ad Minh/)
        end

        click_on 'Role'

        within 'table' do
          expect(page).to have_content(/Ad Minh.*John Everyman/)
        end
      end

      it 'allows sorting by service' do
        click_on 'Service'

        within 'table' do
          expect(page).to have_content(/Ad Minh.*Super Visor/)
        end
      end

      it 'allows sorting by email' do
        click_on 'Email'

        within 'table' do
          expect(page).to have_content(/Ad Minh.*John Everyman/)
        end
      end
    end
  end

  describe '#create' do
    before do
      sign_in supervisor
      visit users_path
      click_on I18n.t('users.index.add_new_user')
    end

    it 'can create a new user' do
      fill_in I18n.t('users.form.field.first_name'), with: 'Joe'
      fill_in I18n.t('users.form.field.last_name'), with: 'Bloggs'
      fill_in I18n.t('users.form.field.email'), with: Faker::Internet.email
      choose I18n.t('users.form.field.supervisor.title')

      click_on I18n.t('users.form.save')

      expect(User.count).to eq(8)
      expect(page).to have_content('Joe Bloggs')
    end

    it 'cannot create a user with an existing email' do
      fill_in I18n.t('users.form.field.first_name'), with: 'Joe'
      fill_in I18n.t('users.form.field.last_name'), with: 'Bloggs'
      fill_in I18n.t('users.form.field.email'), with: supervisor.email
      choose I18n.t('users.form.field.supervisor.title')

      click_on I18n.t('users.form.save')

      expect(page).to have_content(I18n.t('activemodel.errors.models.user_form.attributes.email.taken'))
    end
  end

  describe '#update' do
    before do
      sign_in supervisor
      visit users_path
      click_on caseworker.display_name
      expect(page).to have_content(I18n.t('users.edit.page_title'))
    end

    it "can update a user's name" do
      fill_in I18n.t('users.form.field.first_name'), with: 'Joe'
      fill_in I18n.t('users.form.field.last_name'), with: 'Bloggs'
      click_on I18n.t('users.form.save')

      expect(page).to have_content('Joe Bloggs')
      expect(page).not_to have_content('John Everyman')
    end

    it "can update a user's role" do
      choose I18n.t('users.form.field.viewer.title')
      click_on I18n.t('users.form.save')

      expect(find('tr', text: caseworker.display_name).has_text?(I18n.t('users.form.field.viewer.title'))).to be(true)
    end

    it "can update the service for a user's role" do
      choose I18n.t('users.service.pa'), match: :first
      click_on I18n.t('users.form.save')

      expect(find('tr', text: caseworker.display_name).has_text?('PA')).to be(true)
    end

    it 'cannot update a user without a last name' do
      fill_in I18n.t('users.form.field.last_name'), with: ''

      click_on I18n.t('users.form.save')

      expect(page).to have_content(I18n.t('activemodel.errors.models.user_form.attributes.last_name.blank'))
    end
  end

  describe 'Permissions' do
    it 'correctly blocks user access' do
      # Caseworker can see PA
      sign_in caseworker
      visit users_path

      expect(page).to have_content(I18n.t('home.index.prior_authority'))

      # Supervisor revokes caseworker access
      sign_in supervisor
      visit users_path
      click_on caseworker.display_name
      expect(page).to have_content(I18n.t('users.edit.page_title'))
      choose I18n.t('users.form.field.none.title')

      click_on I18n.t('users.form.save')

      # Caseworker can't access anything
      sign_in caseworker
      visit users_path

      expect(page).to have_content(I18n.t('errors.unauthorised'))
      expect(caseworker.reload.deactivated_at).not_to be_nil

      # Supervisor reinstates caseworker access
      sign_in supervisor
      visit users_path
      click_on caseworker.display_name
      expect(page).to have_content(I18n.t('users.edit.page_title'))
      choose I18n.t('users.form.field.caseworker.title')
      choose I18n.t('users.service.pa'), match: :first

      click_on I18n.t('users.form.save')

      # Caseworker can see PA
      sign_in caseworker
      visit users_path

      expect(page).to have_content(I18n.t('home.index.prior_authority'))
      expect(caseworker.reload.deactivated_at).to be_nil
    end
  end
end
