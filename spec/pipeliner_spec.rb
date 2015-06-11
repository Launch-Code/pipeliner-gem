require 'spec_helper'

describe Pipeliner do
	before { Pipeliner.initialize 'us_LC1_HU96U9XZ6JBOB07V', '3V8EfF70LbqMkFPb'  }
  it 'has a version number' do
    expect(Pipeliner::VERSION).not_to be nil
  end

  it 'should return candidates' do
    candidates = Pipeliner.grab_a_few_candidates
		expect(candidates.count).to be== 25
	end

	it 'paginate candidates' do
		candidates = Pipeliner.grab_more_candidates(1)
		expect(candidates.headers['content-range']).to include '25'
		expect(candidates.headers['content-range']).to include '49'
	end

	it 'can parse the candidate total from the headers' do
		expect(Pipeliner.total_rows 'items 0-24/1044').to be== 1044
	end

	it 'can grab all candidates' do
		candidates = Pipeliner.grab_all_candidates
		expect(candidates.count).to be== Pipeliner.total_rows(candidates.headers['content-range'])
	end

	it 'can grab all opportunities' do
		opportunities = Pipeliner.grab_all('Opportunities')
		expected_number_of_opportunities = Pipeliner.grab_a_few('Opportunities').headers['content-range'].split('/').last.to_i
		expect(opportunities.count).to eq expected_number_of_opportunities
	end

	it 'can grab all contacts' do
		contacts = Pipeliner.grab_all_contacts
		expected_number_of_contacts = Pipeliner.grab_a_few('Contacts').headers['content-range'].split('/').last.to_i
		expect(contacts.count).to eq expected_number_of_contacts
	end

	it 'can grab data' do
		expect(Pipeliner.grab_some_data.count).to be== 25
	end

	it 'can grab all the data' do
		data = Pipeliner.grab_all_data
		expect(data.count).to be== Pipeliner.total_rows(data.headers['content-range'])
	end

	it 'can grab all the notes' do
		notes = Pipeliner.grab_all_candidate_notes
		expect(notes.count).to be== Pipeliner.total_rows(notes.headers['content-range'])
	end

	it 'every note should have an email address' do
		notes = Pipeliner.grab_all_candidate_notes
		expect(notes[0][:email]).to_not be_nil
	end
end
