require 'spec_helper'

describe 'SECURITY.md' do
  let(:path) do
    File.expand_path(File.join(File.dirname(__FILE__), '..', 'SECURITY.md'))
  end

  let(:content) { File.read(path) }

  it 'exists' do
    expect(File.file?(path)).to be(true)
  end

  it 'contains private reporting guidance' do
    expect(content).to include('Reporting A Vulnerability')
    expect(content).to include('Do not open a public GitHub issue')
  end

  it 'contains a security contact channel' do
    expect(content).to include('postmodern.mod3@gmail.com')
  end
end
