# frozen_string_literal: true

require "spec_helper"

describe "rake search_missing_translations", type: :task do
  let(:manifest_name) { "proposals" }
  let(:reportable_classes_list) { [Decidim::Proposals::Proposal] }
  let(:organization) { create(:organization, available_locales: %w(en ca es)) }
  let(:participatory_proces) { create(:participatory_process, organization:) }
  let(:user) { create :user, :admin, organization:, id: 1 }
  let(:component) do
    create(:proposal_component,
           participatory_space: participatory_proces)
  end

  before do
    Decidim::TranslationAddons::ReportDetail.delete_all
    Decidim::TranslationAddons::Report.delete_all
    reportable_classes_list.each(&:delete_all)
    user.id = 1
  end

  context "when execute the task" do
    it "without failures" do
      Rake::Task[:"decidim:translation_addons:search_missing_translations"].reenable
      expect { Rake::Task[:"decidim:translation_addons:search_missing_translations"].invoke }.not_to raise_error
    end

    it "and creates a report and report detail when records have missing translations" do
      create(:proposal, title: { "en" => "Test english", "ca" => "Test ca" }, component:)
      Rake::Task[:"decidim:translation_addons:search_missing_translations"].reenable
      Rake::Task["decidim:translation_addons:search_missing_translations"].invoke
      expect(Decidim::TranslationAddons::Report.count).to eq(1)
      expect(Decidim::TranslationAddons::ReportDetail.count).to eq(1)
    end
  end
end
