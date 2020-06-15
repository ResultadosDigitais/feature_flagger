# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FeatureFlagger::KeyDecomposer do
  describe '.decompose' do
    it 'decompose the feature key as an resource_name and feature_key' do
      input_key = 'class_name:this:is:some:interesting:composition:of:keys'
      expect(described_class.decompose(input_key)).to eq(['class_name', %w[this is some interesting composition of keys]])
    end
  end
end
