require 'rspec'
require_relative 'helpers'

Before do
  @browsers = {}
  @locations = {}
end

World(Helpers)

Given(/^the following geo locations:$/) do |locations|
  locations.hashes.each do |name_lat_long|
    location = name_lat_long['name']
    lat      = name_lat_long['lat']
    long     = name_lat_long['long']
    @locations[location] = [lat.to_f, long.to_f]
  end
end

Given(/^(\w+) is in (.*?)$/) do |person_name, location|
  # Replace :selenium with :rack_test for faster, headless tests
  browser = Capybara::Session.new(:rack_test, ShoutyApp)
  geo_location = @locations[location]
  url = "/?lat=#{geo_location[0]}&lon=#{geo_location[1]}"
  browser.visit(url)
  @browsers[person_name] = browser
end

When(/^(\w+) shouts "(.*?)"$/) do |person_name, message|
  someone_shouts(person_name, message)
end

When(/^(\w+) shouts:$/) do |person_name, message|
  someone_shouts(person_name, message)
end

Then(/^(\w+) should hear the message$/) do |person_name|
  browser = @browsers[person_name]
  browser.visit(browser.current_path)
  expect(browser).to have_content(@shouted_message)
end

Then(/^(\w+) should not hear the message$/) do |person_name|
  browser = @browsers[person_name]
  browser.visit(browser.current_path)
  expect(browser).to_not have_content(@shouted_message)
end

Then(/^(\w+) should not hear any messages$/) do |person_name|
  browser = @browsers[person_name]
  browser.visit(browser.current_path)
  expect(browser.all('li').length).to eq(0)
end
