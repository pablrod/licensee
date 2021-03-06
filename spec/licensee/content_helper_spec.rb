class ContentHelperTestHelper
  include Licensee::ContentHelper
  attr_accessor :content

  DEFAULT_CONTENT = <<-EOS.freeze
Copyright 2016 Ben Balter

The made
up  license.
-----------
  EOS

  def initialize(content = nil)
    @content = content || DEFAULT_CONTENT
  end
end

RSpec.describe Licensee::ContentHelper do
  subject { ContentHelperTestHelper.new }
  let(:mit) { Licensee::License.find('mit') }

  it 'creates the wordset' do
    expect(subject.wordset).to eql(Set.new(%w(the made up license)))
  end

  it 'knows the length' do
    expect(subject.length).to eql(20)
  end

  it 'knows the max delta' do
    expect(subject.max_delta).to eql(1)
  end

  it 'knows the length delta' do
    expect(subject.length_delta(mit)).to eql(1012)
    expect(subject.length_delta(subject)).to eql(0)
  end

  it 'knows the similarity' do
    expect(subject.similarity(mit)).to be_within(1).of(4)
    expect(subject.similarity(subject)).to eql(100.0)
  end

  it 'calculates the hash' do
    expect(subject.hash).to eql('3c59634b9fae4396a76a978f3f6aa718ed790a9a')
  end

  context 'normalizing' do
    let(:normalized_content) { subject.content_normalized }

    it 'strips copyright' do
      expect(normalized_content).to_not match 'Copyright'
      expect(normalized_content).to_not match 'Ben Balter'
    end

    it 'downcases' do
      expect(normalized_content).to_not match 'The'
      expect(normalized_content).to match 'the'
    end

    it 'strips HRs' do
      expect(normalized_content).to_not match '---'
    end

    it 'squeezes whitespace' do
      expect(normalized_content).to_not match '  '
    end

    it 'strips whitespace' do
      expect(normalized_content).to_not match(/\n/)
    end

    it 'normalize the content' do
      expect(normalized_content).to eql 'the made up license.'
    end
  end
end
