source 'https://rubygems.org'
ruby "2.3.1"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.2'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'minitest-spec-rails',  '~> 5.4'
  gem 'dotenv-rails',         '~> 2.2'
  gem 'webmock',              '~> 2.3', '>= 2.3.2'
  gem 'timecop',              '~> 0.8.1'
  gem 'bullet',               '~> 5.5', '>= 5.5.1'
  gem 'brakeman',             '~> 3.5'
  gem 'rubocop',              '~> 0.47.1', require: false
  gem 'faker',                '~> 1.7', '>= 1.7.3'
  gem 'vcr',                  '~> 3.0', '>= 3.0.3'
end

group :development do
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

#
# Base additions
#
gem 'oj',                 '~> 2.18', '>= 2.18.2'      # Fast JSON lib
gem 'nokogiri',           '~> 1.7', '>= 1.7.0.1'      # doc parser
gem 'pry-rails',          '~> 0.3.5'                  # better irb
gem 'knock',              '~> 2.1.1'                  # jwt token auth
gem 'rollbar',            '~> 2.14'                   # exception reporting
gem 'redis',              '~> 3.3.3'                  # memory db
gem 'redis-namespace',    '~> 1.5', '>= 1.5.3'        # namespace redis db
gem 'dalli',              '~> 2.7', '>= 2.7.6'        # memcache lib
gem 'lograge',            '~> 0.4.1'                  # log formatter
gem 'json-schema',        '~> 2.8'                    # JSON schema tools
gem 'hashie',             '~> 3.5', '>= 3.5.5'        # Nested Hash -> Object lib
gem 'premailer-rails',    '~> 1.9', '>= 1.9.5'        # inline css for mailers
gem 'kaminari',           '~> 0.16.1'                 # API response pagination 
gem 'savon',              '~> 2.11', '>= 2.11.1'      # SOAP lib for calling BridgePay API
gem 'audited',            '~> 4.4', '>= 4.4.1'        # Audit tracking lib
gem 'rqrcode',            '~> 0.10.1'                 # QR code generation
gem 'aws-sdk',            '~> 2.9', '>= 2.9.6'        # Amazon AWS services
gem 'barby',              '~> 0.6.5'                  # Barcode lib
gem 'barby-pdf417',       '~> 0.1.2'                  # PDF417 barcode format                         
gem 'sidekiq',            '~> 5.0'                    # background processing
gem 'twilio-ruby',        '~> 4.13'                   # SMS/MMS provider
gem 'phony',              '~> 2.15', '>= 2.15.44'     # Normalize phone numbers
