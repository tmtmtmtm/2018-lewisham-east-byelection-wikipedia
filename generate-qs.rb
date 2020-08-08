#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pry'
require 'scraped'

require_relative 'lib/quickstatement_candidate'

wd = 'Q55099347'
source = 'https://en.wikipedia.org/wiki/2018_Lewisham_East_by-election'
csvfile = 'combo.csv'
new_person_description = 'UK election candidate'

csv = CSV.table(csvfile)

commands = csv.map do |row|
  data = row.to_h
  data[:id] ||= data.delete(:foundid)
  QuickStatement::Candidate.new(data.merge(election: wd, url: source, description: new_person_description)).to_s
end

puts commands.join("\n")
