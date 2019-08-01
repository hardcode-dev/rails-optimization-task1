require "spec_helper"
load "task-1.rb"

RSpec.describe "File Parsing" do
  context "check performance" do
    it "should take us less than 30 seconds" do
      expect { work("data_large.txt", disable_gc: true) }.to perform_under(30).sec
    end
  end
end