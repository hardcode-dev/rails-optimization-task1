require './task1'

describe 'Task1' do
  let(:data_file_path) { 'spec/fixtures/data.txt' }
  let(:output_file_path) { 'result.json' }
  let(:expected_output) { File.read('spec/fixtures/expected_output.json') }

  before { File.delete(output_file_path) if File.exists?(output_file_path) }
  after { File.delete(output_file_path) if File.exists?(output_file_path) }

  it 'return expected data' do
    work(data_file_path)
    expect(File.read(output_file_path)).to eq(expected_output)
  end
end
