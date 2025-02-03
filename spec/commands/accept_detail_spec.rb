# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TranslationAddons
    describe AcceptDetail do
      let(:current_organization) { create(:organization) }
      let(:current_user) { create(:user, :admin, organization: meeting_component.organization) }
      let(:reporting_user) { create(:user, organization: meeting_component.organization) }
      let(:meeting_component) { create(:meeting_component) }
      let(:meeting) { create(:meeting, component: meeting_component, title: { en: "Test val en", ca: "test val ca" }) }
      let!(:translation_addons_report) { create(:translation_addons_report, decidim_resource_id: meeting.id, decidim_resource_type: meeting.class, locale: current_organization.available_locales[0], field_name: "title") }
      let!(:translation_addons_report_detail) { create(:translation_addons_report_detail, decidim_translation_addons_report_id: translation_addons_report.id, decidim_user_id: reporting_user.id, reason: "wrong") }
      let(:new_value) { "new test val" }

      describe "when the call is invalid" do
        let(:command) { described_class.new(nil, current_user, new_value) }

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "does not remove ReportDetail" do
          expect do
            command.call
          end.not_to change(Decidim::TranslationAddons::ReportDetail, :count)
        end
      end

      describe "when the call is valid" do
        let(:command) { described_class.new(translation_addons_report_detail, current_user, new_value) }
        let(:report_locale) { translation_addons_report.locale }
        let(:report_field) { translation_addons_report.field_name }

        it "broadcasts ok" do 
          expect { command.call }.to broadcast(:ok)
        end

        it "removes ReportDetail" do
          expect do
            command.call
          end.to change(Decidim::TranslationAddons::ReportDetail, :count).by(-1)
        end

        context "when call was successfull" do
          let(:report_detail_report_resource) { translation_addons_report_detail.report.resource }

          before do
            command.call
          end

          it "changes the value of the field on the report locale" do
            expect(report_detail_report_resource[report_field][report_locale]).to eq(new_value)
          end
        end
      end
    end
  end
end
