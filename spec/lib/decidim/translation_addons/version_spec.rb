# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe TranslationAddons do
    subject { described_class }

    it "has version" do
      expect(subject.version).to eq("0.30.0.dev")
    end
  end
end
