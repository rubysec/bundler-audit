require 'bundler/audit/task'

describe Bundler::Audit::Task do
  let(:task) { Bundler::Audit::Task.new }

  context "default options" do
    it "runs bundle-audit check" do
      task = Bundler::Audit::Task.new(:audit_task)
      expect(Bundler::Audit::CLI).to receive(:start)
      task.send(:run)
    end

    it "creates task name" do
      task = Bundler::Audit::Task.new(:audit_task)
      expect(task.name).to eq(:audit_task)
      expect(task).to receive(:run) { true }
      Rake.application.invoke_task("audit_task")
    end

    it "can fail" do
      task = Bundler::Audit::Task.new(:failed_audit)
      Rake.application.invoke_task("failed_audit")
    end
  end

  context "verbose" do
    it "correctly adds verbose to the command" do
      task = Bundler::Audit::Task.new(:audit_test_1) do |r|
        r.verbose = true
      end
      expect(Bundler::Audit::CLI).to receive(:start).with ['check', '-v']
      Rake.application.invoke_task("audit_test_1")
    end
  end
end
