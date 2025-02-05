# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/faker/localized"
require "decidim/dev"

require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :translation_addons_report, class: "Decidim::TranslationAddons::Report" do
    transient do
      skip_injection { false }
    end
  end

  factory :translation_addons_report_detail, class: "Decidim::TranslationAddons::ReportDetail" do
    transient do
      skip_injection { false }
    end
  end
end
