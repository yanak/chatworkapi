require 'rspec'
require_relative '../src/API'

describe 'API behaviour' do
  before {
    @api = API.new
  }

  shared_examples 'weekly weather' do
    it { expect(subject.class).to be(Hash) }
    it { is_expected.to have_key('2014/09/04')}
  end

  describe 'weekly weather' do
    subject { @api.weekly_weather }
    it_behaves_like 'weekly weather'
  end
end