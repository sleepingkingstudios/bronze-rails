# spec/bronze/rails/resources/resource_spec.rb

require 'rails_helper'

require 'bronze/rails/resources/resource'
require 'bronze/rails/resources/resource/associations_examples'
require 'bronze/rails/resources/resource/base_examples'
require 'bronze/rails/resources/resource/names_examples'
require 'bronze/rails/resources/resource/routing_examples'
require 'bronze/rails/resources/resource/templates_examples'

require 'fixtures/entities/archived_periodical'
require 'fixtures/entities/book'
require 'fixtures/entities/chapter'
require 'fixtures/entities/section'

RSpec.describe Bronze::Rails::Resources::Resource do
  include Spec::Resources::Resource::BaseExamples
  include Spec::Resources::Resource::AssociationsExamples
  include Spec::Resources::Resource::NamesExamples
  include Spec::Resources::Resource::RoutingExamples
  include Spec::Resources::Resource::TemplatesExamples

  let(:resource_class)   { Spec::Book }
  let(:resource_options) { {} }
  let(:instance) do
    described_class.new resource_class, resource_options
  end # let

  include_examples 'should implement the Resource::Base methods'

  include_examples 'should implement the Resource::Associations methods'

  include_examples 'should implement the Resource::Names methods'

  include_examples 'should implement the Resource::Routing methods'

  include_examples 'should implement the Resource::Templates methods'

  describe '::new' do
    describe 'with a block' do
      let(:resource_class) { Spec::Chapter }
      let(:instance) do
        described_class.new(resource_class, resource_options) do
          namespace :admin
          namespace :api

          parent_resource Spec::Book
        end # described_class
      end # let

      it 'should declare the namespaces' do
        expect(instance.namespaces.count).to be 3

        namespace = instance.namespaces[0]
        expect(namespace).to be == { :name => :admin, :type => :namespace }

        namespace = instance.namespaces[1]
        expect(namespace).to be == { :name => :api, :type => :namespace }

        namespace = instance.namespaces[2]
        expect(namespace.fetch :name).to be :books
        expect(namespace.fetch :type).to be :resource

        resource = namespace.fetch(:resource)
        expect(resource.resource_class).to be Spec::Book
        expect(resource.resource_name).to be == 'book'
        expect(resource.namespaces).to be == instance.namespaces[0...-1]
      end # it
    end # describe
  end # describe
end # describe
