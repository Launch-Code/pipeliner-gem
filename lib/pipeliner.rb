require "pipeliner/version"
require 'httparty'

module Pipeliner
	include HTTParty
	format :json
	basic_auth 'us_LC1_HM2NKTQAJ2Q2I87B', 'jKNomMFAFzou7hKB'
	base_uri 'https://us.pipelinersales.com/rest_services/v1/us_LC1'

	def self.grab_a_few_candidates
		get('/Contacts')
	end

	def self.grab_more_candidates(page)
		get('/Contacts', query: {offset: page*25}) 
	end

	def self.grab_all_candidates
		page = 0 
		all_candidates = get('/Contacts') 
		while ( (page * 25) < Pipeliner.total_rows(all_candidates.headers['content-range'])) do
		#while ( (page * 25) < 51) do
			page = page + 1
			all_candidates.concat(get('/Contacts', query: {offset: page*25})) 
		end
		all_candidates
	end

	def self.grab_some_data
		get('/Data?prettyprint=true')
	end

	def self.grab_all_data
		page = 0
		all_data = get('/Data?prettyprint=true')
		while ( (page * 25) < Pipeliner.total_rows(all_data.headers['content-range'])) do
			page = page + 1
			all_data.concat(get('/Data?prettyprint=true', query: {offset: page*25}))
		end
		all_data	
	end

	def self.grab_all_candidate_notes
		page = 0
		all_data = get('/Notes', query: {filter: 'ADDRESSBOOK_ID::::ne'})
		while ( (page * 25) < Pipeliner.total_rows(all_data.headers['content-range'])) do
			page = page + 1
			all_data.concat(get('/Notes', query: {filter: 'ADDRESSBOOK_ID::::ne'}))
		end
	
		# grab all users of pipeliner and populate email addresses
		all_users = Pipeliner.grab_all_users
		data_hash = Hash[all_users.map { |sym| [sym['ID'], sym['EMAIL']] }]
		all_candidates = Pipeliner.grab_all_candidates
		candidates_hash = Hash[all_candidates.map { |sym| [sym['ID'], sym['EMAIL1']] } ]
		all_data.each do |row|
			row[:email] = data_hash[row['OWNER_ID']]
			row[:candidate_email] = candidates_hash[row['ADDRESSBOOK_ID']]
		end

		all_data
	end

	def self.grab_all_users
		page = 0
		all_clients = get('/Clients')
		while ( (page * 25) < Pipeliner.total_rows(all_clients.headers['content-range'])) do
			page = page + 1
			all_clients.concat(get('/Clients', query: {offset: page*25} ))
		end
		all_clients
	end

	def self.total_rows(offset_header)
		offset_header.split('/')[1].to_i
	end
end
