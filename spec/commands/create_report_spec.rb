# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TranslationAddons
    describe CreateReport do
      let(:current_organization) { create(:organization) }
      let(:current_user) { create(:user, organization: meeting_component.organization) }
      let(:meeting_component) { create(:meeting_component) }
      let(:meeting) { create(:meeting, component: meeting_component) }
      let(:form_params) do
        {
          "field" => :title,
          "locale" => :es,
          "reason" => :wrong
        }
      end

      let(:form) do
        Decidim::TranslationAddons::ReportTranslationForm.from_params(
          form_params
        ).with_context(
          current_organization:,
          current_user:
        )
      end

      let(:command) { described_class.new(form, meeting, current_user) }

      describe "when the form is invalid" do
        before do
          form.reason = nil
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "does not create Report / ReportDetail" do
          expect do
            command.call
          end.not_to change(Decidim::TranslationAddons::Report, :count)
        end
      end

      describe "when the form is valid" do
        before do
          form.reason = "wrong"
        end

        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "creates a Report and ReportDetail" do
          expect do
            command.call
          end.to change(Decidim::TranslationAddons::Report, :count).by(1).and change(Decidim::TranslationAddons::ReportDetail, :count).by(1)
        end

        it "creates answers with the correct information" do
          command.call
          expect(Decidim::TranslationAddons::Report.first.resource.id).to eq(meeting.id)
          expect(Decidim::TranslationAddons::Report.first.resource.class).to eq(meeting.class)
          expect(Decidim::TranslationAddons::Report.first.field_name).to eq(form.field)
          expect(Decidim::TranslationAddons::Report.first.locale).to eq(form.locale)
        end
      end
    end
  end
end
