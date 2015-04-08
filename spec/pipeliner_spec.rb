require 'spec_helper'

describe Pipeliner do
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
		expect(Pipeliner.candidate_total 'items 0-24/1044').to be== 1044
	end

	it 'can grab all candidates' do
		candidates = Pipeliner.grab_all_candidates
		expect(candidates.count).to be== Pipeliner.candidate_total(candidates.headers['content-range'])
	end
end
