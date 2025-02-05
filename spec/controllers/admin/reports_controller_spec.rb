# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TranslationAddons
    module Admin
      describe ReportsController do
        routes { Decidim::TranslationAddons::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let(:reporting_user) { create(:user, organization:) }
        let(:participatory_process) { create(:participatory_process, organization:) }
        let(:meeting_component) { create(:meeting_component, :with_creation_enabled, participatory_space: participatory_process) }
        let(:meeting) { create(:meeting, :published, component: meeting_component, title: { "en" => "Title in en" }) }
        let(:report) { create(:translation_addons_report, decidim_resource_id: meeting.id, decidim_resource_type: meeting.class, locale: "en", field_name: "title") }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.participatory_space"] = participatory_process
          request.env["decidim.current_component"] = meeting_component
          sign_in user, scope: :admin
        end

        context "when clicking the \"Report translation\" section from admin" do
          it "displays the reports" do
            allow(controller).to receive(:current_user) { user }
            get :index
            expect(response).to render_template(:index)
            expect(flash[:alert]).to be_blank
            expect(flash[:notice]).to be_blank
          end

          it "displays the report details" do
            allow(controller).to receive(:current_user) { user }
            get :index, :params => { :report_id => report.id }
            expect(response).to render_template(:index)
            expect(flash[:alert]).to be_blank
            expect(flash[:notice]).to be_blank
          end

          it "unreports with success" do
            expect(Decidim::TranslationAddons::Report.exists?(id: report.id)).to be(true)

            allow(controller).to receive(:current_user) { user }
            put :unreport, :params => { :id => report.id }
            expect(flash[:notice]).to eq(I18n.t("unreport.success", scope: "decidim.admin"))

            expect(Decidim::TranslationAddons::Report.exists?(id: report.id)).to be(false)
          end

          it "unreports as user is not permitted" do
            expect(Decidim::TranslationAddons::Report.exists?(id: report.id)).to be(true)

            allow(controller).to receive(:current_user) { create(:user, :confirmed, organization:) }
            put :unreport, :params => { :id => report.id }
            expect(flash[:alert]).to eq("You are not authorized to perform this action.")

            expect(Decidim::TranslationAddons::Report.exists?(id: report.id)).to be(true)
          end

          it "request a translation with success" do
            allow(controller).to receive(:current_user) { user }
            post :request_translation, :params => { :id => report.id }
            expect(flash[:notice]).to eq(I18n.t("translation_request.success", scope: "decidim.admin"))
          end

          it "request a translation as a user is not permitted" do
            allow(controller).to receive(:current_user) { create(:user, :confirmed, organization:) }
            post :request_translation, :params => { :id => report.id }
            expect(flash[:alert]).to eq("You are not authorized to perform this action.")
          end
        end
      end
    end
  end
end
