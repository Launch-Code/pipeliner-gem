require "pipeliner/version"
require 'httparty'
require 'typhoeus'

module Pipeliner
	include HTTParty
  def self.initialize (username, secret)
		@username = username
		@secret = secret
    basic_auth @username, @secret
    base_uri 'https://us.pipelinersales.com/rest_services/v1/us_LC1'
    format :json
  end

	def self.grab_a_few(collection)
		get("/#{collection}")
	end

	def self.grab_more(collection, page)
		get("/#{collection}", query: {offset: page*25})
	end

	def self.grab_all_candidates
		self.grab_all 'Contacts'
	end

	def self.grab_all_opportunities (options = {})
		default = {filter: ['IS_ARCHIVE::1::ne']}.merge(options)
		self.grab_all 'Opportunities', default
	end

	def self.grab_all(collection, options = {})
		load_only_query = options[:load_only].nil? || options[:load_only].empty? ? '' : '&loadonly=' + options[:load_only].join('|')
		remove_archived = options[:filters].nil? || options[:filters].empty? ? '' : '&filter=' + options[:filters].join('|')
		page = 0
		all_collection = get("/#{collection}")
		requests = []
		hydra = Typhoeus::Hydra.new max_concurrency: 100
		while ( (page * 25) < Pipeliner.total_rows(all_collection.headers['content-range'])) do
			request =  Typhoeus::Request.new("https://us.pipelinersales.com/rest_services/v1/us_LC1/#{collection}?offset=#{page*25}#{remove_archived}#{load_only_query}", userpwd: "#{@username}:#{@secret}")
			hydra.queue request
			requests.push request
			page += 1
		end
		hydra.run
		requests.map { |req| JSON.parse(req.response.body) }.flatten
	end

	def self.grab_all_data
		data = grab_all('Data')
		Hash[data.map { |sym| [sym['ID'].to_s, sym['VALUE']] }]
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
