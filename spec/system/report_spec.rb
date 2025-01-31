# frozen_string_literal: true

require "spec_helper"

describe "Report" do
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
           component:)
  end

  let(:component) do
    create(:meeting_component,
           :with_creation_enabled,
           participatory_space: participatory_process)
  end

  context "with elements correctly displayed" do
    before do
      login_as user, scope: :user
      switch_to_host user.organization.host
      visit resource_locator(meeting).path
    end

    it "shows the \"Report translation\" button and modal" do
      within ".layout-aside__section.actions__secondary" do
        expect(page).to have_css("button[title='Report translation']")
      end

      click_link_or_button "Report translation"
      expect(find("div#flagTranslationModal-#{meeting.id}")["aria-hidden"]).to eq("false")
    end

    it "displays the correct modal content" do
      click_link_or_button "Report translation"

      within "div#flagTranslationModal-#{meeting.id}" do
        expect(page).to have_content(t("decidim.shared.flag_modal.translation.title"))
        expect(page).to have_content(t("decidim.shared.flag_modal.translation.description"))
        expect(page).to have_select(name: "report[field]")
        expect(page).to have_css("select#report_field[required='required']")
        expect(page).to have_css("input[type='radio'][value='missing']")
        expect(page).to have_css("input[type='radio'][value='wrong']")
        expect(page).to have_field(name: "report[detail]")
      end
    end

    it "displays the translatable fields in the modal" do
      click_link_or_button "Report translation"
      translatable_fields = meeting.class.translatable_fields_list

      within "select#report_field" do
        translatable_fields.each do |field|
          expect(page).to have_css("option[value='#{field}']")
        end
      end
    end

    it "submit the modal successfully" do
      expect(Decidim::TranslationAddons::Report.count).to eq(0)

      click_link_or_button "Report translation"

      within "div#flagTranslationModal-#{meeting.id}" do
        within "label[for='report_field']" do
          all("#report_field option")[1].select_option
        end
        find("input#translation-suggestion").fill_in(with: "Dummy suggestion")

        click_link_or_button "Report"
      end

      expect(page).to have_css(".flash__message")
      expect(Decidim::TranslationAddons::Report.count).to eq(0)
    end
  end

  context "when reporting a translation as guest" do
    it "the login modal appears" do
      logout :user
      switch_to_host user.organization.host
      visit resource_locator(meeting).path

      within ".layout-aside__section.actions__secondary" do
        expect(page).to have_css("button[title='Report translation']")
      end

      click_link_or_button "Report translation"
      expect(find("div#loginModal")["aria-hidden"]).to eq("false")
    end
  end
end
