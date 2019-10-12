require 'rails_helper'
require 'requests_helper'

RSpec.describe 'the creation of a group process', :js do
  before do
    load_database
    @user = create(:user)
    login_as @user, scope: :user
  end

  after do
    logout(:user)
  end

  it 'creates a group correctly and view main administration pages' do
    visit new_group_path
    expect(page).to have_title I18n.t('pages.groups.new.title')
    expect(page).to have_content(I18n.t('pages.groups.new.new_group'))
    # fill form fields
    group_name = Faker::Company.name
    within('#main-copy') do
      fill_in I18n.t('activerecord.attributes.group.name'), with: group_name
      fill_in_ckeditor 'group_description', with: Faker::Lorem.paragraph
      fill_tokeninput '#group_tags_list', with: %w[tag1 tag2 tag3]
      select2ajax('#group_interest_border_tkn', Country.first.description)
      fill_in I18n.t('activerecord.attributes.group.default_role_name'), with: Faker::Name.prefix
      click_button I18n.t('pages.groups.new.create_button')
    end
    expect(page).to have_content group_name
    @group = Group.order(created_at: :desc).first
    # the group name is certainly displayed somewhere
    expect(page).to have_current_path(group_path(@group))
    # the user is a participant
    expect(page).to have_selector('.participants_container', text: /#{@user.name}/i)

    visit group_proposals_path(@group)
    page_should_be_ok

    visit group_events_path(@group)
    page_should_be_ok

    visit group_documents_path(@group)
    page_should_be_ok

    visit group_forums_path(@group)
    page_should_be_ok

    # group settings administration
    visit edit_group_path(@group)
    page_should_be_ok

    # roles administration
    visit group_participation_roles_path(@group)
    page_should_be_ok

    # users administration
    visit group_group_participations_path(@group)
    page_should_be_ok

    # quorums administration
    visit group_quorums_path(@group)
    page_should_be_ok

    # group areas administration
    visit group_group_areas_path(@group)
    page_should_be_ok

    # forum administration
    visit group_frm_admin_root_path(@group)
    page_should_be_ok
  end
end
