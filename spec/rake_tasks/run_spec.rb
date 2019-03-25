require 'spec_helper'
require 'rake'
require 'fileutils'
require 'byebug'

describe 'rake after_party:run' do
  include FileUtils

  before(:all) do
    AfterParty::Application.load_tasks

    FILE_PATH = File.join(Rails.root, 'spec/fixtures/tasks/deployment/')
    silence_warnings do
      AfterParty::TaskRecorder::FILE_MASK = File.join(FILE_PATH, '/*.rake')
    end
  end

  context 'When tasks are pending' do
    after(:all) do
      AfterParty::TaskRecord.delete_all
    end

    it 'should log the tasks that have run' do
      expect(AfterParty::TaskRecord.count).to be(0)
      Dir.glob(AfterParty::TaskRecorder::FILE_MASK).each { |r| load r }
      Rake::Task['after_party:run'].invoke
      expect(AfterParty::TaskRecord.all.map(&:version)).to eq(%w[20120205141454 20130205176456 20130207948264])
    end
  end
end
