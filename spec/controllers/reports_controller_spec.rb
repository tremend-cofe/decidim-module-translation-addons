# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TranslationAddons
    describe ReportsController do
      routes { Decidim::TranslationAddons::Engine.routes }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, organization:) }
      let(:reporting_user) { create(:user, organization:) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:meeting_component) { create(:meeting_component, :with_creation_enabled, participatory_space: participatory_process) }
      let(:meeting) { create(:meeting, :published, component: meeting_component, title: { "en" => "Title in en" }) }
      let(:report) { create(:translation_addons_report, decidim_resource_id: meeting.id, decidim_resource_type: meeting.class, locale: "en", field_name: "title") }
      let(:report_detail) { create(:translation_addons_report_detail, decidim_translation_addons_report_id: report.id, decidim_user_id: reporting_user1.id, reason: "missing") }

      before do
        request.env["decidim.current_organization"] = organization
        request.env["decidim.participatory_space"] = participatory_process
        request.env["decidim.current_component"] = meeting_component
        sign_in user, scope: :user
      end

      context "when clicking the \"Report translation\" button and modals open" do
        it "successfully creates a report" do
          get :create, :params => {
            :field => "title",
            :locale => "en",
            :reason => "wrong",
            :detail => "Dummy text",
            :sgid => meeting.to_sgid
          }
          expect(flash[:notice]).to eq(I18n.t("decidim.reports.create.success"))
        end

        it "form is incorrect and throws error" do
          get :create, :params => {
            :reason => "wrong",
            :sgid => meeting.to_sgid
          }
          expect(flash[:alert]).to eq(I18n.t("decidim.reports.create.error"))
        end
      end
    end
  end
end
