# frozen_string_literal: true

require "spec_helper"

describe "Report" do
  include_context "with a component"
  let(:manifest_name) { "meetings" }
  let(:admin) { create(:user, :admin, :confirmed) }
  let(:organization) { admin.organization }
  let(:reporting_user1) { create(:user, organization:) }
  let(:reporting_user2) { create(:user, organization:) }
  let(:component) { create(:meeting_component) }
  let!(:meeting) do
    create(:meeting,
           :published,
           :past,
           title: { en: "Meeting title", es: "Title in es" },
           description: { en: "Meeting description" },
           component:)
  end
  let!(:report) { create(:translation_addons_report, decidim_resource_id: meeting.id, decidim_resource_type: meeting.class, locale: organization.available_locales[0], field_name: "title") }
  let!(:report_detail1) { create(:translation_addons_report_detail, decidim_translation_addons_report_id: report.id, decidim_user_id: reporting_user1.id, reason: "wrong") }
  let!(:report_detail2) { create(:translation_addons_report_detail, decidim_translation_addons_report_id: report.id, decidim_user_id: reporting_user2.id, reason: "wrong") }

  before do
    switch_to_host(organization.host)
  end

  describe "Report Translation" do
    before do
      login_as admin, scope: :user
      visit decidim_admin.root_path
      click_on "Global moderations"
      within_admin_sidebar_menu do
        click_on "Translation Reports"
      end
    end

    it "redirects to the correct path" do
      expect(page).to have_current_path(decidim_admin_translation_addons.root_path)
    end

    it "dashboard displays correct info" do
      within "table.table-list" do
        expect(page).to have_content(report.id)
        expect(page).to have_content(report.resource.id)
        expect(page).to have_content(report.resource.class.name.demodulize)
        expect(page).to have_content(report.field_name.capitalize)
        expect(page).to have_content(report.locale)
      end
    end

    it "removes the report when clicking the \"Unreport\" button" do
      within "table.table-list" do
        expect(page).to have_content(report.id)
        expect(page).to have_content(report.resource.id)
        expect(page).to have_content(report.resource.class.name.demodulize)
        expect(page).to have_content(report.field_name.capitalize)
        expect(page).to have_content(report.locale)

        click_link_or_button "Unreport"
      end

      expect(page).to have_css("div.flash.success")
      within "table.table-list" do
        expect(page).to have_no_content(report.id)
        expect(page).to have_no_content(report.resource.id)
        expect(page).to have_no_content(report.resource.class.name.demodulize)
        expect(page).to have_no_content(report.field_name.capitalize)
        expect(page).to have_no_content(report.locale)
      end
    end

    it "sends the translation request successfully" do
      within "table.table-list" do
        click_link_or_button "Run translation service"
      end

      within "div.flash.success" do
        expect(page).to have_content(I18n.t("translation_request.success", scope: "decidim.admin"))
      end
    end

    context "when clicking on \"Configure\"" do
      it "displays report details" do
        report_details = [report_detail1, report_detail2]
        within "table.table-list" do
          click_link_or_button "Configure"
        end
        expect(page).to have_current_path(decidim_admin_translation_addons.report_report_details_path(report_id: report.id))

        within ".report-details-table" do
          report_details.each do |report_detail|
            expect(page).to have_content(report_detail.id)
            expect(page).to have_content(report_detail.decidim_user_id)
            expect(page).to have_content(report_detail.reason.capitalize)
            expect(page).to have_content(report_detail.fix_suggestion)
            expect(page).to have_content(report_detail.created_at.strftime("%d/%m/%Y %H:%M"))
          end
        end
      end

      it "removes the report details when clicking on \"Decline\"" do
        visit decidim_admin_translation_addons.report_report_details_path(report_id: report.id)
        click_link_or_button("Decline report", match: :first)

        within "div.flash.success" do
          expect(page).to have_content(I18n.t("report_details.decline.success", scope: "decidim.admin"))
        end
        expect(page).to have_current_path(decidim_admin_translation_addons.reports_path)

        within "table.table-list" do
          click_link_or_button "Configure"
        end

        within ".report-details-table" do
          expect(page).to have_no_content(report_detail1.id)
          expect(page).to have_no_content(report_detail1.decidim_user_id)
        end
      end

      it "accept the report" do
        visit decidim_admin_translation_addons.report_report_details_path(report_id: report.id)
        click_link_or_button("Accept report", match: :first)

        within "#acceptTranslationModal-#{report_detail1.id}" do
          find("input#report_detail_field_translation").fill_in(with: "Correct translation")
          click_link_or_button "Save"
        end

        within "div.flash.success" do
          expect(page).to have_content(I18n.t("report_details.accept.success", scope: "decidim.admin"))
        end
        expect(page).to have_current_path(decidim_admin_translation_addons.reports_path)

        within ".report-table" do
          expect(page).to have_no_content(report.id)
          expect(page).to have_no_content(report.resource.id)
        end
      end
    end
  end
end
