# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TranslationAddons
    describe RequestTranslation do
      let(:current_organization) { create(:organization, default_locale: "en") }
      let(:current_user) { create(:user, :admin, organization: meeting_component.organization) }
      let(:reporting_user) { create(:user, organization: meeting_component.organization) }
      let(:meeting_component) { create(:meeting_component) }
      let(:meeting) { create(:meeting, component: meeting_component, title: { en: "Test val en", ca: "test val ca" }) }
      let!(:translation_addons_report) { create(:translation_addons_report, decidim_resource_id: meeting.id, decidim_resource_type: meeting.class, locale: current_organization.available_locales[0], field_name: "title") }
      let!(:translation_addons_report_detail) { create(:translation_addons_report_detail, decidim_translation_addons_report_id: translation_addons_report.id, decidim_user_id: reporting_user.id, reason: "wrong") }

      describe "when the call is invalid" do
        let(:command) { described_class.new(nil, current_user) }

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end
      end

      describe "when the call is valid" do
        let(:command) { described_class.new(translation_addons_report, current_user) }

        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        context "when call was successfull" do
          before do
            clear_enqueued_jobs
            command.call
          end

          it "changes the value of the field on the report locale" do
            expect(translation_addons_report.auto_translation_retry_count).to eq(1)
            expect(translation_addons_report.auto_translation_retry_count).not_to be_nil
          end

          it "enqueues the machine translation fields job" do
            source_locale = translation_addons_report.resource.respond_to?(:organization) ? translation_addons_report.resource.organization.default_locale.to_s : current_organization.available_locales.first.to_s
            if translation_addons_report.field_with_merged_machine_translations[source_locale].blank?
              source_locale = translation_addons_report.field_with_merged_machine_translations.first[0]
            end
            expect(Decidim::MachineTranslationFieldsJob)
              .to have_been_enqueued
              .on_queue("translations")
              .exactly(1).times
              .with(
                translation_addons_report.resource,
                translation_addons_report.field_name,
                translation_addons_report.field_with_merged_machine_translations[source_locale],
                translation_addons_report.locale,
                source_locale
              )
          end
        end
      end
    end
  end
end
