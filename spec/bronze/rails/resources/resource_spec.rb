# spec/bronze/rails/resources/resource_spec.rb

require 'bronze/rails/resources/resource'

require 'fixtures/entities/archived_periodical'
require 'fixtures/entities/book'
require 'fixtures/entities/chapter'
require 'fixtures/entities/section'

RSpec.describe Bronze::Rails::Resources::Resource do
  shared_context 'when the resource has many namespaces' do
    let(:namespaces) do
      [
        { :name => :admin, :type => :namespace },
        { :name => :api,   :type => :namespace }
      ] # end namespaces
    end # let

    before(:example) do
      allow(instance).to receive(:namespaces).and_return(namespaces)
    end # before
  end # shared_context

  shared_context 'when the resource has a namespace and a parent resource' do
    let(:book)           { Spec::Book.new }
    let(:resource_class) { Spec::Chapter }
    let(:resources) do
      {
        :books => Bronze::Rails::Resources::Resource.new(Spec::Book)
      } # end resources
    end # let
    let(:namespaces) do
      [
        { :name => :admin, :type => :namespace },
        {
          :name     => :books,
          :type     => :resource,
          :resource => resources[:books]
        } # end books
      ] # end namespaces
    end # let

    before(:example) do
      allow(resources[:books]).
        to receive(:namespaces).
        and_return(namespaces[0..0])

      allow(instance).to receive(:namespaces).and_return(namespaces)
    end # before
  end # shared_context

  shared_context 'when the resource has many parent resources' do
    let(:book)           { Spec::Book.new }
    let(:chapter)        { Spec::Chapter.new }
    let(:resource_class) { Spec::Section }
    let(:resources) do
      {
        :books    => Bronze::Rails::Resources::Resource.new(Spec::Book),
        :chapters => Bronze::Rails::Resources::Resource.new(Spec::Chapter)
      } # end resources
    end # let
    let(:namespaces) do
      [
        {
          :name     => :books,
          :type     => :resource,
          :resource => resources[:books]
        }, # end books
        {
          :name     => :chapters,
          :type     => :resource,
          :resource => resources[:chapters]
        } # end chapters
      ] # end namespaces
    end # let

    before(:example) do
      allow(resources[:chapters]).
        to receive(:namespaces).
        and_return(namespaces[0..0])

      allow(instance).to receive(:namespaces).and_return(namespaces)
    end # before
  end # shared_context

  shared_context 'when the resource class has a compound name' do
    let(:resource_class) { Spec::ArchivedPeriodical }
  end # shared_context

  let(:resource_class)   { Spec::Book }
  let(:resource_options) { {} }
  let(:instance) do
    described_class.new resource_class, resource_options
  end # let

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1..2).arguments }

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
        expect(resource.resource_name).to be == 'books'
        expect(resource.namespaces).to be == instance.namespaces[0...-1]
      end # it
    end # describe
  end # describe

  describe '#association_key' do
    include_examples 'should have reader', :association_key, :book

    it 'should alias the method' do
      expect(instance).to alias_method(:association_key).as(:parent_key)
    end # it

    context 'when options[:association_name] is set' do
      let(:resource_options) do
        super().merge :association_name => 'tome'
      end # let

      it { expect(instance.association_key).to be == :tome }
    end # context

    context 'when options[:resource_name] is set' do
      let(:resource_options) do
        super().merge :resource_name => 'tome'
      end # let

      it { expect(instance.association_key).to be == :tome }
    end # context
  end # describe

  describe '#association_name' do
    include_examples 'should have reader',
      :association_name,
      ->() { be == 'book' }

    it 'should alias the method' do
      expect(instance).to alias_method(:association_name).as(:parent_name)
    end # it

    context 'when options[:association_name] is a singular string' do
      let(:resource_options) do
        super().merge :association_name => 'tome'
      end # let

      it { expect(instance.association_name).to be == 'tome' }
    end # context

    context 'when options[:association_name] is a plural string' do
      let(:resource_options) do
        super().merge :association_name => 'tomes'
      end # let

      it { expect(instance.association_name).to be == 'tomes' }
    end # context

    context 'when options[:association_name] is a singular symbol' do
      let(:resource_options) do
        super().merge :association_name => :tome
      end # let

      it { expect(instance.association_name).to be == 'tome' }
    end # context

    context 'when options[:association_name] is a plural symbol' do
      let(:resource_options) do
        super().merge :association_name => :tomes
      end # let

      it { expect(instance.association_name).to be == 'tomes' }
    end # context

    context 'when options[:resource_name] is set' do
      let(:resource_options) { super().merge :resource_name => :tomes }

      it { expect(instance.association_name).to be == 'tome' }
    end # context
  end # describe

  describe '#collection_name' do
    include_examples 'should have reader',
      :collection_name,
      ->() { be == 'spec-books' }

    context 'when options[:collection_name] is a plural string' do
      let(:resource_options) { super().merge :collection_name => 'tomes' }

      it { expect(instance.collection_name).to be == 'tomes' }
    end # context

    context 'when options[:collection_name] is a plural symbol' do
      let(:resource_options) { super().merge :collection_name => :tomes }

      it { expect(instance.collection_name).to be == 'tomes' }
    end # context

    context 'when options[:collection_name] is a singular string' do
      let(:resource_options) { super().merge :collection_name => 'tome' }

      it { expect(instance.collection_name).to be == 'tome' }
    end # context

    context 'when options[:collection_name] is a singular symbol' do
      let(:resource_options) { super().merge :collection_name => :tome }

      it { expect(instance.collection_name).to be == 'tome' }
    end # context

    wrap_context 'when the resource class has a compound name' do
      it 'should return the collection name' do
        expect(instance.collection_name).
          to be == 'spec-archived_periodicals'
      end # it
    end # wrap_context
  end # describe

  describe '#controller_name' do
    include_examples 'should have reader',
      :controller_name,
      ->() { be == 'books' }

    context 'when options[:controller_name] is a class name' do
      let(:resource_options) do
        super().merge :controller_name => 'TomesController'
      end # let

      it { expect(instance.controller_name).to be == 'tomes' }
    end # context

    context 'when options[:controller_name] is a string' do
      let(:resource_options) do
        super().merge :controller_name => 'tomes'
      end # let

      it { expect(instance.controller_name).to be == 'tomes' }
    end # context

    context 'when options[:controller_name] is a symbol' do
      let(:resource_options) do
        super().merge :controller_name => :tomes
      end # let

      it { expect(instance.controller_name).to be == 'tomes' }
    end # context

    context 'when options[:resource_name] is set' do
      let(:resource_options) { super().merge :resource_name => :tome }

      it { expect(instance.controller_name).to be == 'tomes' }
    end # context
  end # describe

  describe '#default_resource_key' do
    include_examples 'should have reader', :default_resource_key, :books

    it 'should alias the method' do
      expect(instance).
        to alias_method(:default_resource_key).
        as(:default_plural_resource_key)
    end # it

    context 'when options[:resource_name] is set' do
      let(:resource_options) { super().merge :resource_name => 'tomes' }

      it { expect(instance.default_resource_key).to be == :books }
    end # context

    wrap_context 'when the resource class has a compound name' do
      it 'should return the default resource name' do
        expect(instance.default_resource_key).
          to be == :archived_periodicals
      end # it
    end # wrap_context
  end # describe

  describe '#default_resource_name' do
    include_examples 'should have reader',
      :default_resource_name,
      ->() { be == 'books' }

    it 'should alias the method' do
      expect(instance).
        to alias_method(:default_resource_name).
        as(:default_plural_resource_name)
    end # it

    context 'when options[:resource_name] is set' do
      let(:resource_options) { super().merge :resource_name => 'tomes' }

      it { expect(instance.default_resource_name).to be == 'books' }
    end # context

    wrap_context 'when the resource class has a compound name' do
      it 'should return the default resource name' do
        expect(instance.default_resource_name).
          to be == 'archived_periodicals'
      end # it
    end # wrap_context
  end # describe

  describe '#default_singular_resource_key' do
    include_examples 'should have reader', :default_singular_resource_key, :book

    context 'when options[:resource_name] is set' do
      let(:resource_options) { super().merge :resource_name => 'tomes' }

      it { expect(instance.default_singular_resource_key).to be == :book }
    end # context

    context 'when options[:singular_resource_name] is set' do
      let(:resource_options) { super().merge :singular_resource_name => 'data' }

      it { expect(instance.default_singular_resource_key).to be == :book }
    end # context

    wrap_context 'when the resource class has a compound name' do
      it 'should return the default resource name' do
        expect(instance.default_singular_resource_key).
          to be == :archived_periodical
      end # it
    end # wrap_context
  end # describe

  describe '#default_singular_resource_name' do
    include_examples 'should have reader',
      :default_singular_resource_name,
      ->() { be == 'book' }

    context 'when options[:resource_name] is set' do
      let(:resource_options) { super().merge :resource_name => 'tomes' }

      it { expect(instance.default_singular_resource_name).to be == 'book' }
    end # context

    context 'when options[:singular_resource_name] is set' do
      let(:resource_options) { super().merge :singular_resource_name => 'data' }

      it { expect(instance.default_singular_resource_name).to be == 'book' }
    end # context

    wrap_context 'when the resource class has a compound name' do
      it 'should return the default resource name' do
        expect(instance.default_singular_resource_name).
          to be == 'archived_periodical'
      end # it
    end # wrap_context
  end # describe

  describe '#foreign_key' do
    include_examples 'should have reader', :foreign_key, :book_id

    context 'when options[:association_name] is set' do
      let(:resource_options) do
        super().merge :association_name => 'tomes'
      end # let

      it { expect(instance.foreign_key).to be == :tome_id }
    end # context

    context 'when options[:resource_name] is set' do
      let(:resource_options) do
        super().merge :resource_name => 'tome'
      end # let

      it { expect(instance.foreign_key).to be == :tome_id }
    end # context
  end # describe

  describe '#namespaces' do
    include_examples 'should have reader', :namespaces, []
  end # describe

  describe '#parent_resources' do
    let(:expected) do
      instance.namespaces.
        select { |hsh| hsh[:type] == :resource }.
        map { |hsh| hsh[:resource] }
    end # let

    include_examples 'should have reader', :parent_resources, []

    wrap_context 'when the resource has many namespaces' do
      it { expect(instance.parent_resources).to be == [] }
    end # wrap_context

    wrap_context 'when the resource has a namespace and a parent resource' \
    do
      it { expect(instance.parent_resources).to be == expected }
    end # context

    wrap_context 'when the resource has many parent resources' do
      it { expect(instance.parent_resources).to be == expected }
    end # context
  end # describe

  describe '#primary_key' do
    include_examples 'should have reader', :primary_key, :book_id

    context 'when options[:primary_key] is set' do
      let(:resource_options) { super().merge :primary_key => :tome_id }

      it { expect(instance.primary_key).to be == :tome_id }
    end # context

    context 'when options[:resource_name] is set' do
      let(:resource_options) { super().merge :resource_name => 'tomes' }

      it { expect(instance.primary_key).to be == :tome_id }
    end # context

    wrap_context 'when the resource class has a compound name' do
      it 'should return the primary key' do
        expect(instance.primary_key).to be == :archived_periodical_id
      end # it
    end # wrap_context
  end # describe

  describe '#qualified_resource_name' do
    include_examples 'should have reader',
      :qualified_resource_name,
      ->() { be == 'spec-book' }

    wrap_context 'when the resource class has a compound name' do
      it 'should return the qualified name' do
        expect(instance.qualified_resource_name).
          to be == 'spec-archived_periodical'
      end # it
    end # wrap_context
  end # describe

  describe '#resource_class' do
    include_examples 'should have reader',
      :resource_class,
      ->() { resource_class }
  end # describe

  describe '#resource_key' do
    include_examples 'should have reader', :resource_key, :books

    it 'should alias the method' do
      expect(instance).
        to alias_method(:resource_key).
        as(:plural_resource_key)
    end # it

    context 'when options[:resource_name] is set' do
      let(:resource_options) { super().merge :resource_name => 'tomes' }

      it { expect(instance.resource_key).to be == :tomes }
    end # context

    wrap_context 'when the resource class has a compound name' do
      it 'should return the resource key' do
        expect(instance.resource_key).to be == :archived_periodicals
      end # it
    end # wrap_context
  end # describe

  describe '#resource_name' do
    include_examples 'should have reader',
      :resource_name,
      ->() { be == 'books' }

    it 'should alias the method' do
      expect(instance).
        to alias_method(:resource_name).
        as(:plural_resource_name)
    end # it

    context 'when options[:resource_name] is a plural string' do
      let(:resource_options) { super().merge :resource_name => 'tomes' }

      it { expect(instance.resource_name).to be == 'tomes' }
    end # context

    context 'when options[:resource_name] is a plural symbol' do
      let(:resource_options) { super().merge :resource_name => :tomes }

      it { expect(instance.resource_name).to be == 'tomes' }
    end # context

    context 'when options[:resource_name] is a singular string' do
      let(:resource_options) { super().merge :resource_name => 'tome' }

      it { expect(instance.resource_name).to be == 'tomes' }
    end # context

    context 'when options[:resource_name] is a singular symbol' do
      let(:resource_options) { super().merge :resource_name => :tome }

      it { expect(instance.resource_name).to be == 'tomes' }
    end # context

    wrap_context 'when the resource class has a compound name' do
      it 'should return the resource name' do
        expect(instance.resource_name).to be == 'archived_periodicals'
      end # it
    end # wrap_context
  end # describe

  describe '#resource_name_changed?' do
    include_examples 'should have predicate', :resource_name_changed?, false

    context 'when options[:singular_resource_name] is set' do
      let(:resource_options) do
        super().merge :singular_resource_name => 'tomes'
      end # let

      it { expect(instance.resource_name_changed?).to be true }
    end # context

    context 'when options[:resource_name] is set' do
      let(:resource_options) { super().merge :resource_name => 'tome' }

      it { expect(instance.resource_name_changed?).to be true }
    end # context

    wrap_context 'when the resource class has a compound name' do
      it { expect(instance.resource_name_changed?).to be false }
    end # wrap_context
  end # describe

  describe '#resource_options' do
    include_examples 'should have reader',
      :resource_options,
      ->() { be == resource_options }

    describe 'with custom resource options with string keys' do
      let(:resource_options) { { :custom_option => 'custom value' } }
      let(:expected) do
        tools.hash.convert_keys_to_symbols(resource_options)
      end # let

      it { expect(instance.resource_options).to be == expected }
    end # describe
  end # describe

  describe '#resource_key' do
    include_examples 'should have reader', :singular_resource_key, :book

    context 'when options[:resource_name] is set' do
      let(:resource_options) { super().merge :resource_name => 'tomes' }

      it { expect(instance.singular_resource_key).to be == :tome }
    end # context

    context 'when options[:singular_resource_name] is set' do
      let(:resource_options) { super().merge :singular_resource_name => 'data' }

      it { expect(instance.singular_resource_key).to be == :data }
    end # context

    wrap_context 'when the resource class has a compound name' do
      it 'should return the resource key' do
        expect(instance.singular_resource_key).to be == :archived_periodical
      end # it
    end # wrap_context
  end # describe

  describe '#serialization_key' do
    include_examples 'should have reader',
      :serialization_key,
      ->() { be == :books }

    it 'should alias the method' do
      expect(instance).
        to alias_method(:serialization_key).
        as(:plural_serialization_key)
    end # it

    context 'when options[:resource_name] is set' do
      let(:resource_options) { super().merge :resource_name => 'tomes' }

      it { expect(instance.serialization_key).to be == :tomes }
    end # context

    context 'when options[:serialization_key] is a plural string' do
      let(:resource_options) do
        super().merge :serialization_key => 'tomes'
      end # let

      it { expect(instance.serialization_key).to be == :tomes }
    end # context

    context 'when options[:serialization_key] is a plural symbol' do
      let(:resource_options) do
        super().merge :serialization_key => :tomes
      end # let

      it { expect(instance.serialization_key).to be == :tomes }
    end # context

    context 'when options[:serialization_key] is a singular string' do
      let(:resource_options) do
        super().merge :serialization_key => 'tomes'
      end # let

      it { expect(instance.serialization_key).to be == :tomes }
    end # context

    context 'when options[:serialization_key] is a singular symbol' do
      let(:resource_options) do
        super().merge :serialization_key => :tomes
      end # let

      it { expect(instance.serialization_key).to be == :tomes }
    end # context

    wrap_context 'when the resource class has a compound name' do
      it 'should return the resource name' do
        expect(instance.serialization_key).to be == :archived_periodicals
      end # it
    end # wrap_context
  end # describe

  describe '#serialization_key_changed?' do
    include_examples 'should have predicate', :serialization_key_changed?, false

    context 'when options[:resource_name] is set' do
      let(:resource_options) { super().merge :resource_name => 'tomes' }

      it { expect(instance.serialization_key_changed?).to be true }
    end # context

    context 'when options[:serialization_key] is set' do
      let(:resource_options) { super().merge :serialization_key => :tomes }

      it { expect(instance.serialization_key_changed?).to be true }
    end # context

    context 'when options[:singular_resource_name] is set' do
      let(:resource_options) do
        super().merge :singular_resource_name => 'tome'
      end # let

      it { expect(instance.serialization_key_changed?).to be true }
    end # context

    context 'when options[:singular_serialization_key] is set' do
      let(:resource_options) do
        super().merge :singular_serialization_key => :tomes
      end # let

      it { expect(instance.serialization_key_changed?).to be true }
    end # context

    wrap_context 'when the resource class has a compound name' do
      it { expect(instance.serialization_key_changed?).to be false }
    end # wrap_context
  end # describe

  describe '#singular_resource_key' do
    include_examples 'should have reader', :singular_resource_key, :book

    context 'when options[:resource_name] is set' do
      let(:resource_options) { super().merge :resource_name => 'tomes' }

      it { expect(instance.singular_resource_key).to be == :tome }
    end # context

    context 'when options[:singular_resource_name] is set' do
      let(:resource_options) do
        super().merge :singular_resource_name => 'data'
      end # let

      it { expect(instance.singular_resource_key).to be == :data }
    end # context

    wrap_context 'when the resource class has a compound name' do
      it 'should return the resource name' do
        expect(instance.singular_resource_key).to be == :archived_periodical
      end # it
    end # wrap_context
  end # describe

  describe '#singular_resource_name' do
    include_examples 'should have reader',
      :singular_resource_name,
      ->() { be == 'book' }

    context 'when options[:resource_name] is a plural string' do
      let(:resource_options) { super().merge :resource_name => 'tomes' }

      it { expect(instance.singular_resource_name).to be == 'tome' }
    end # context

    context 'when options[:resource_name] is a plural symbol' do
      let(:resource_options) { super().merge :resource_name => :tomes }

      it { expect(instance.singular_resource_name).to be == 'tome' }
    end # context

    context 'when options[:resource_name] is a singular string' do
      let(:resource_options) { super().merge :resource_name => 'tome' }

      it { expect(instance.singular_resource_name).to be == 'tome' }
    end # context

    context 'when options[:resource_name] is a singular symbol' do
      let(:resource_options) { super().merge :resource_name => :tome }

      it { expect(instance.singular_resource_name).to be == 'tome' }
    end # context

    context 'when options[:singular_resource_name] is set' do
      let(:resource_options) do
        super().merge :singular_resource_name => 'data'
      end # let

      it { expect(instance.singular_resource_name).to be == 'data' }
    end # context

    wrap_context 'when the resource class has a compound name' do
      it 'should return the resource name' do
        expect(instance.singular_resource_name).to be == 'archived_periodical'
      end # it
    end # wrap_context
  end # describe

  describe '#singular_serialization_key' do
    include_examples 'should have reader', :singular_serialization_key, :book

    context 'when options[:singular_serialization_key] is a plural string' do
      let(:resource_options) do
        super().merge :singular_serialization_key => 'tomes'
      end # let

      it { expect(instance.singular_serialization_key).to be == :tomes }
    end # context

    context 'when options[:singular_serialization_key] is a plural symbol' do
      let(:resource_options) do
        super().merge :singular_serialization_key => :tomes
      end # let

      it { expect(instance.singular_serialization_key).to be == :tomes }
    end # context

    context 'when options[:singular_serialization_key] is a singular string' \
    do
      let(:resource_options) do
        super().merge :singular_serialization_key => 'tome'
      end # let

      it { expect(instance.singular_serialization_key).to be == :tome }
    end # context

    context 'when options[:singular_serialization_key] is a singular symbol' \
    do
      let(:resource_options) do
        super().merge :singular_serialization_key => :tome
      end # let

      it { expect(instance.singular_serialization_key).to be == :tome }
    end # context

    context 'when options[:singular_serialization_key] is ' \
            'an ambiguous string' do
      let(:resource_options) do
        super().merge :singular_serialization_key => 'data'
      end # let

      it { expect(instance.singular_serialization_key).to be == :data }
    end # context

    context 'when options[:singular_serialization_key] is ' \
            'an ambiguous symbol' do
      let(:resource_options) do
        super().merge :singular_serialization_key => :data
      end # let

      it { expect(instance.singular_serialization_key).to be == :data }
    end # context

    context 'when options[:resource_name] is set' do
      let(:resource_options) { super().merge :resource_name => 'tome' }

      it { expect(instance.singular_serialization_key).to be == :tome }
    end # context

    context 'when options[:serialization_key] is set' do
      let(:resource_options) { super().merge :serialization_key => :tomes }

      it { expect(instance.singular_serialization_key).to be == :tome }
    end # context

    wrap_context 'when the resource class has a compound name' do
      it 'should return the resource key' do
        expect(instance.singular_serialization_key).
          to be == :archived_periodical
      end # it
    end # wrap_context
  end # describe
end # describe
