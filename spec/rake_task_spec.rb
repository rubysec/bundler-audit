
require 'bundler/audit/rake_task'

describe Bundler::Audit::RakeTask do
  let(:task) { Bundler::Audit::RakeTask.new }

  context "default options" do
    it "runs bundle-audit check" do
      expect(task.command).to match(/bundle-audit check$/)
    end

    it "creates task name" do
      task = Bundler::Audit::RakeTask.new(:audit_task)
      expect(task.name).to eq(:audit_task)
      expect(task).to receive(:run) { true }
      Rake.application.invoke_task("audit_task")
    end

    it "can fail" do
      task = Bundler::Audit::RakeTask.new(:failed_audit)
      expect(task).to receive(:command) { 'ruby -e "exit(2)";' }
      expect(task).to receive(:exit).with(2)
      expect($stderr).to receive(:puts) { |cmd| expect(cmd).to match(/failed/) }
      Rake.application.invoke_task("failed_audit")
    end
  end

  context "verbose" do
    it "correctly adds verbose to the command" do
      task = Bundler::Audit::RakeTask.new(:audit_test_1) do |r|
        r.verbose = true
      end
      expect(task).to receive(:run) { true }
      Rake.application.invoke_task("audit_test_1")
      expect(task.command).to match(/-v/)
    end
  end
end
