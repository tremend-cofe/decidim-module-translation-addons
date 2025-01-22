# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gem "concurrent-ruby", "= 1.3.4"

gem "decidim", "~> 0.29"
gem "decidim-translation_addons", path: "."

gem "bootsnap", "~> 1.4"
gem "puma", ">= 6.3"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "faker"

  gem "decidim-dev", "~> 0.29"

  gem "rubocop-performance"
  gem "simplecov", require: false
end

group :development do
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "web-console", "~> 4.2"
end

group :test do
  gem "rubocop-faker"
end
