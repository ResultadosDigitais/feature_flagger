require 'spec_helper'

module Rollout

  class DummyClass
    include Rollout::Model
    def id; 14 end
  end

  RSpec.describe Model do
    subject   { DummyClass.new }
    let(:key) { [:email_marketing, :whitelabel] }

    before do
      filepath = File.expand_path('../../fixtures/rollout_example.yml', __FILE__)
      info = YAML.load_file(filepath)
      allow(Rollout).to receive(:config).and_return(info: info)
    end

    describe '#release!' do
      it 'calls Control#release! with appropriated methods' do
        expect_any_instance_of(Control).to receive(:release!).with(key, subject.id, 'rollout_dummy_class')
        subject.release!(key)
      end
    end

    describe '#rollout?' do
      it 'calls Control#rollout? with appropriated methods' do
        expect_any_instance_of(Control).to receive(:rollout?).with(key, subject.id, 'rollout_dummy_class')
        subject.rollout?(key)
      end
    end

    describe '#unrelease!' do
      it 'calls Control#unrelease! with appropriated methods' do
        expect_any_instance_of(Control).to receive(:unrelease!).with(key, subject.id, 'rollout_dummy_class')
        subject.unrelease!(key)
      end
    end
  end
end
