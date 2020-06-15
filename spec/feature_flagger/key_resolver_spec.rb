# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FeatureFlagger::KeyResolver do
  let(:subject) do
   described_class.new([:this,:is,[:some,[:interesting, :composition],:of],:keys], 'class_name')
 end

  describe '.normalized_key' do
    it 'normalize the feature key as an array of strings' do
      expect(subject.normalized_key).to eq(%w[this is some interesting composition of keys])
    end
  end

  describe '.normalized_key_with_name' do
    it 'normalize key with class_name appended' do
      normalized_key_with_name = %w[class_name this is some interesting composition of keys]
      expect(subject.normalized_key_with_name).to eq(normalized_key_with_name)
    end
  end
end
