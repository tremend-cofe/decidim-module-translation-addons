# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TranslationAddons
    module Admin
      describe ReportDetailsController do
        routes { Decidim::TranslationAddons::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let(:reporting_user1) { create(:user, organization:) }
        let(:reporting_user2) { create(:user, organization:) }
        let(:participatory_process) { create(:participatory_process, organization:) }
        let(:meeting_component) { create(:meeting_component, :with_creation_enabled, participatory_space: participatory_process) }
        let(:meeting) { create(:meeting, :published, component: meeting_component, title: { "en" => "Title in en" }) }
        let(:report) { create(:translation_addons_report, decidim_resource_id: meeting.id, decidim_resource_type: meeting.class, locale: "en", field_name: "title") }
        let(:report_detail1) { create(:translation_addons_report_detail, decidim_translation_addons_report_id: report.id, decidim_user_id: reporting_user1.id, reason: "missing") }
        let(:report_detail2) { create(:translation_addons_report_detail, decidim_translation_addons_report_id: report.id, decidim_user_id: reporting_user2.id, reason: "missing") }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.participatory_space"] = participatory_process
          request.env["decidim.current_component"] = meeting_component
          sign_in user, scope: :admin
        end

        context "when clicking \"Configure\" button on a report" do
          it "decline a report with success" do
            expect(Decidim::TranslationAddons::ReportDetail.exists?(id: report_detail1.id)).to be(true)

            allow(controller).to receive(:current_user) { user }
            put :decline, :params => { :report_id => report.id, :id => report_detail1.id }
            expect(flash[:notice]).to eq(I18n.t("report_details.decline.success_with_report_deleted", scope: "decidim.admin"))

            expect(Decidim::TranslationAddons::ReportDetail.exists?(id: report_detail1.id)).to be(false)
          end

          it "decline all reports with success" do
            expect(Decidim::TranslationAddons::ReportDetail.exists?(id: report_detail1.id)).to be(true)
            expect(Decidim::TranslationAddons::ReportDetail.exists?(id: report_detail2.id)).to be(true)
            expect(Decidim::TranslationAddons::Report.exists?(id: report.id)).to be(true)

            allow(controller).to receive(:current_user) { user }
            put :decline, :params => { :report_id => report.id, :id => report_detail1.id }
            expect(flash[:notice]).to eq(I18n.t("report_details.decline.success_with_report_deleted", scope: "decidim.admin"))

            put :decline, :params => { :report_id => report.id, :id => report_detail2.id }
            expect(flash[:notice]).to eq(I18n.t("report_details.decline.success_with_report_deleted", scope: "decidim.admin"))

            expect(Decidim::TranslationAddons::ReportDetail.exists?(id: report_detail1.id)).to be(false)
            expect(Decidim::TranslationAddons::ReportDetail.exists?(id: report_detail2.id)).to be(false)
            expect(Decidim::TranslationAddons::Report.exists?(id: report.id)).to be(false)
          end

          it "accept a report with success" do
            expect(Decidim::TranslationAddons::ReportDetail.exists?(id: report_detail1.id)).to be(true)
            expect(Decidim::TranslationAddons::Report.exists?(id: report.id)).to be(true)
            allow(controller).to receive(:current_user) { user }

            post :accept, :params => {
              :report_id => report.id,
              :id => report_detail1.id,
              :field_translation => "Correct translation"
            }

            expect(flash[:notice]).to eq(I18n.t("report_details.accept.success", scope: "decidim.admin"))
            expect(Decidim::TranslationAddons::ReportDetail.exists?(id: report_detail1.id)).to be(false)
            expect(Decidim::TranslationAddons::Report.exists?(id: report.id)).to be(false)
          end
        end
      end
    end
  end
end
