source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.0'

gem 'rails', '~> 6.1.4', '>= 6.1.4.1'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'rspec'
# gem 'jwt'
# gem 'dotenv-rails'
# gem 'jbuilder', '~> 2.7'
# gem 'redis', '~> 4.0'
gem 'bcrypt', '~> 3.1.7'
gem 'carrierwave'
gem 'jsonapi-serializer'
# gem 'email_validator'  

# gem 'image_processing', '~> 1.2'

gem 'bootsnap', '>= 1.4.4', require: false

gem 'rack-cors'
gem 'pdf-reader'
# gem 'open-uri'
group :test do 
  gem 'database_cleaner-active_record'
end 

group :development, :test do
  gem 'rspec-rails', '~> 5.0.0'
  gem 'shoulda-matchers'
  gem 'pry'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'spring'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
