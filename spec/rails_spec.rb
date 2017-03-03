# spec/rails_spec.rb

require 'rails_helper'

RSpec.describe 'Rails' do
  it { expect { ::Rails }.not_to raise_error }
end # describe
