require "pipeliner/version"
require 'httparty'

module Pipeliner
	include HTTParty
	format :json
	basic_auth 'us_CompanyJobPipelineClone_NQ1GLTL79ZNCZGNA', 'jUxKMyb9GmyjFKex'

	def self.grab_a_few_candidates
		get('https://us.pipelinersales.com/rest_services/v1/us_CompanyJobPipelineClone/Contacts')
	end

	def self.grab_more_candidates(page)
		get('https://us.pipelinersales.com/rest_services/v1/us_CompanyJobPipelineClone/Contacts', query: {offset: page*25}) 
	end

	def self.grab_all_candidates
		page = 0 
		all_candidates = get('https://us.pipelinersales.com/rest_services/v1/us_CompanyJobPipelineClone/Contacts') 
		while ( (page * 25) < Pipeliner.total_rows(all_candidates.headers['content-range'])) do
		#while ( (page * 25) < 51) do
			page = page + 1
			all_candidates.concat(get('https://us.pipelinersales.com/rest_services/v1/us_CompanyJobPipelineClone/Contacts', query: {offset: page*25})) 
		end
		all_candidates
	end

	def self.grab_some_data
		get('https://us.pipelinersales.com/rest_services/v1/us_CompanyJobPipelineClone/Data?prettyprint=true')
	end

	def self.grab_all_data
		page = 0
		all_data = get('https://us.pipelinersales.com/rest_services/v1/us_CompanyJobPipelineClone/Data?prettyprint=true')
		while ( (page * 25) < Pipeliner.total_rows(all_data.headers['content-range'])) do
			page = page + 1
			all_data.concat(get('https://us.pipelinersales.com/rest_services/v1/us_CompanyJobPipelineClone/Data?prettyprint=true', query: {offset: page*25}))
		end
		all_data	
	end

	def self.total_rows(offset_header)
		offset_header.split('/')[1].to_i
	end
end
