# frozen_string_literal: true

require "spec_helper"

describe "User reports translation", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:user) { create :user, :confirmed, organization: participatory_process.organization }
  let!(:meeting) do
    create(:meeting,
           :published,
           :past,
           title: { en: "Meeting titleiswrong" },
           description: { en: "Meeting description" },
           location: { en: "Unirii Square" },
           author: user,
           component: component)
  end

  let(:component) do
    create(:meeting_component,
           :with_creation_enabled,
           participatory_space: participatory_process)
  end

  before do
    switch_to_host user.organization.host
    login_as user, scope: :user
    visit resource_locator(meeting).path
  end

  context "elements are correctly displayed" do

    it "shows the \"Report translation\" button and modal" do
      within ".layout-aside__section.actions__secondary" do
        expect(page).to have_css("button[title='Report translation']")
      end

      click_link_or_button "Report translation"
      expect(find("div#flagTranslationModal-#{meeting.id}")["aria-hidden"]).to eq("false")
    end

    #WIP
  end
end


