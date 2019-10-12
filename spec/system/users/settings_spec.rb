require 'rails_helper'
require 'requests_helper'
require 'email_spec'

RSpec.describe 'personal settings', :js do
  let!(:user) { create(:user) }

  before do
    login_as user, scope: :user
  end

  after do
    logout(:user)
  end

  context 'from his settings page' do
    include EmailSpec::Helpers
    include EmailSpec::Matchers

    before do
      visit user_path(user)
    end

    it 'has a message which informs the user that he is able to change is settings' do
      expect(page).to have_content(I18n.t('info.user.click_to_change'))
    end

    it 'can change name' do
      find('#name_profile').click
      new_name = Faker::Name.first_name
      within '#name_modal' do
        find(:css, '#user_name').set new_name
        click_button I18n.t('buttons.save')
      end
      expect(page).to have_content(I18n.t('info.user.info_updated'))
      user.reload
      expect(user.name).to eq new_name
    end

    it 'can change last name' do
      find('#surname_profile').click
      new_name = Faker::Name.last_name
      within '#surname_modal' do
        find(:css, '#user_surname').set new_name
        click_button I18n.t('buttons.save')
      end
      expect(page).to have_content(I18n.t('info.user.info_updated'))
      user.reload
      expect(user.surname).to eq new_name
    end

    it 'can update his email address' do
      user.original_locale.update(lang: '')
      find('#email_profile').click
      new_email = Faker::Internet.email
      within '#email_modal' do
        find(:css, '#user_email').set new_email
        click_button I18n.t('buttons.save')
      end
      expect(page).to have_content(I18n.t('info.user.info_updated'))
      user.reload
      expect(user.unconfirmed_email).to eq new_email

      delivery = ActionMailer::Base.deliveries.last
      expect(delivery.to[0]).to eq new_email
      open_last_email_for(new_email)
      click_first_link_in_email
      expect(page).to have_content(I18n.t('devise.confirmations.user.confirmed'))
    end
  end

  context 'from privacy preferences page' do
    before do
      visit privacy_preferences_users_path
    end

    it 'can enable/disable tooltips' do
      find('#user_show_tooltips').click
      expect(page).to have_content(I18n.t('info.user.tooltips_disabled'))
      user.reload
      expect(user.show_tooltips).to be_falsey

      visit privacy_preferences_users_path
      find('#user_show_tooltips').click
      expect(page).to have_content(I18n.t('info.user.tooltips_enabled'))
      user.reload
      expect(user.show_tooltips).to be_truthy
    end

    it 'can show/hide social network urls' do
      find('#user_show_urls').click
      expect(page).to have_content(I18n.t('info.user.url_hidden'))
      user.reload
      expect(user.show_urls).to be_falsey

      visit privacy_preferences_users_path
      find('#user_show_urls').click
      expect(page).to have_content(I18n.t('info.user.url_shown'))
      user.reload
      expect(user.show_urls).to be_truthy
    end

    it 'can enable/disable messages' do
      find('#user_receive_messages').click
      expect(page).to have_content(I18n.t('info.private_messages_inactive'))
      user.reload
      expect(user.receive_messages).to be_falsey

      visit privacy_preferences_users_path
      find('#user_receive_messages').click
      expect(page).to have_content(I18n.t('info.private_messages_active'))
      user.reload
      expect(user.receive_messages).to be_truthy
    end
  end

  context 'from geographical borders page' do
    it 'can update his geographical borders of interest' do
      municipality = create(:municipality)
      visit border_preferences_users_path
      fill_tokeninput '#user_interest_borders_tokens', with: [InterestBorder.to_key(municipality)]
      click_button I18n.t('buttons.save')
      expect(page).to have_content(I18n.t('info.user.info_updated'))
    end
  end
end
