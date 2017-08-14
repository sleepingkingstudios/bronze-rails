# spec/bronze/rails/resources/resource/names_examples.rb

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'fixtures/entities/archived_periodical'

module Spec::Resources
  module Resource; end
end # module

module Spec::Resources::Resource
  module NamesExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when the resource class has a compound name' do
      let(:resource_class) { Spec::ArchivedPeriodical }
    end # shared_context

    shared_examples 'should implement the Resource::Names methods' do
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

        context 'when options[:plural_resource_name] is set' do
          let(:resource_options) { super().merge :resource_name => :tomes }

          it { expect(instance.controller_name).to be == 'tomes' }
        end # context

        context 'when options[:resource_name] is set' do
          let(:resource_options) { super().merge :resource_name => :tome }

          it { expect(instance.controller_name).to be == 'tomes' }
        end # context
      end # describe

      describe '#default_plural_resource_key' do
        include_examples 'should have reader',
          :default_plural_resource_key,
          ->() { be == :books }

        context 'when options[:plural_resource_name] is set' do
          let(:resource_options) do
            super().merge :plural_resource_name => 'tomes'
          end # let

          it { expect(instance.default_plural_resource_key).to be == :books }
        end # context

        context 'when options[:resource_name] is set' do
          let(:resource_options) { super().merge :resource_name => 'tomes' }

          it { expect(instance.default_plural_resource_key).to be == :books }
        end # context

        wrap_context 'when the resource class has a compound name' do
          it 'should return the default resource name' do
            expect(instance.default_plural_resource_key).
              to be == :archived_periodicals
          end # it
        end # wrap_context
      end # describe

      describe '#default_plural_resource_name' do
        include_examples 'should have reader',
          :default_plural_resource_name,
          ->() { be == 'books' }

        context 'when options[:plural_resource_name] is set' do
          let(:resource_options) do
            super().merge :plural_resource_name => 'tomes'
          end # let

          it { expect(instance.default_plural_resource_name).to be == 'books' }
        end # context

        context 'when options[:resource_name] is set' do
          let(:resource_options) { super().merge :resource_name => 'tomes' }

          it { expect(instance.default_plural_resource_name).to be == 'books' }
        end # context

        wrap_context 'when the resource class has a compound name' do
          it 'should return the default resource name' do
            expect(instance.default_plural_resource_name).
              to be == 'archived_periodicals'
          end # it
        end # wrap_context
      end # describe

      describe '#default_resource_key' do
        include_examples 'should have reader',
          :default_resource_key,
          ->() { be == :book }

        context 'when options[:resource_name] is set' do
          let(:resource_options) { super().merge :resource_name => 'tomes' }

          it { expect(instance.default_resource_key).to be == :book }
        end # context

        wrap_context 'when the resource class has a compound name' do
          it 'should return the default resource name' do
            expect(instance.default_resource_key).
              to be == :archived_periodical
          end # it
        end # wrap_context
      end # describe

      describe '#default_resource_name' do
        include_examples 'should have reader',
          :default_resource_name,
          ->() { be == 'book' }

        context 'when options[:resource_name] is set' do
          let(:resource_options) { super().merge :resource_name => 'tomes' }

          it { expect(instance.default_resource_name).to be == 'book' }
        end # context

        wrap_context 'when the resource class has a compound name' do
          it 'should return the default resource name' do
            expect(instance.default_resource_name).
              to be == 'archived_periodical'
          end # it
        end # wrap_context
      end # describe

      describe '#plural_resource_key' do
        include_examples 'should have reader',
          :plural_resource_key,
          ->() { be == :books }

        context 'when options[:plural_resource_name] is set' do
          let(:resource_options) do
            super().merge :plural_resource_name => 'tomes'
          end # let

          it { expect(instance.plural_resource_key).to be == :tomes }
        end # context

        context 'when options[:resource_name] is set' do
          let(:resource_options) do
            super().merge :resource_name => 'tome'
          end # let

          it { expect(instance.plural_resource_key).to be == :tomes }
        end # context

        wrap_context 'when the resource class has a compound name' do
          it 'should return the plural resource name' do
            expect(instance.plural_resource_key).
              to be == :archived_periodicals
          end # it
        end # wrap_context
      end # describe

      describe '#plural_resource_name' do
        include_examples 'should have reader',
          :plural_resource_name,
          ->() { be == 'books' }

        context 'when options[:plural_resource_name] is a plural string' do
          let(:resource_options) do
            super().merge :plural_resource_name => 'tomes'
          end # let

          it { expect(instance.plural_resource_name).to be == 'tomes' }
        end # context

        context 'when options[:plural_resource_name] is a plural symbol' do
          let(:resource_options) do
            super().merge :plural_resource_name => :tomes
          end # let

          it { expect(instance.plural_resource_name).to be == 'tomes' }
        end # context

        context 'when options[:plural_resource_name] is a singular string' do
          let(:resource_options) do
            super().merge :plural_resource_name => 'tome'
          end # let

          it { expect(instance.plural_resource_name).to be == 'tome' }
        end # context

        context 'when options[:plural_resource_name] is a singular symbol' do
          let(:resource_options) do
            super().merge :plural_resource_name => :tome
          end # let

          it { expect(instance.plural_resource_name).to be == 'tome' }
        end # context

        context 'when options[:plural_resource_name] is an ambiguous string' do
          let(:resource_options) do
            super().merge :plural_resource_name => 'data'
          end # let

          it { expect(instance.plural_resource_name).to be == 'data' }
        end # context

        context 'when options[:plural_resource_name] is an ambiguous symbol' do
          let(:resource_options) do
            super().merge :plural_resource_name => :data
          end # let

          it { expect(instance.plural_resource_name).to be == 'data' }
        end # context

        context 'when options[:resource_name] is a plural string' do
          let(:resource_options) { super().merge :resource_name => 'tomes' }

          it { expect(instance.plural_resource_name).to be == 'tomes' }
        end # context

        context 'when options[:resource_name] is a plural symbol' do
          let(:resource_options) { super().merge :resource_name => :tomes }

          it { expect(instance.plural_resource_name).to be == 'tomes' }
        end # context

        context 'when options[:resource_name] is a singular string' do
          let(:resource_options) { super().merge :resource_name => 'tome' }

          it { expect(instance.plural_resource_name).to be == 'tomes' }
        end # context

        context 'when options[:resource_name] is a singular symbol' do
          let(:resource_options) { super().merge :resource_name => :tome }

          it { expect(instance.plural_resource_name).to be == 'tomes' }
        end # context

        wrap_context 'when the resource class has a compound name' do
          it 'should return the plural resource name' do
            expect(instance.plural_resource_name).
              to be == 'archived_periodicals'
          end # it
        end # wrap_context
      end # describe

      describe '#plural_serialization_key' do
        include_examples 'should have reader',
          :plural_serialization_key,
          ->() { be == :books }

        context 'when options[:plural_serialization_key] is a plural string' do
          let(:resource_options) do
            super().merge :plural_serialization_key => 'tomes'
          end # let

          it { expect(instance.plural_serialization_key).to be == :tomes }
        end # context

        context 'when options[:plural_serialization_key] is a plural symbol' do
          let(:resource_options) do
            super().merge :plural_serialization_key => :tomes
          end # let

          it { expect(instance.plural_serialization_key).to be == :tomes }
        end # context

        context 'when options[:plural_serialization_key] is a singular string' \
        do
          let(:resource_options) do
            super().merge :plural_serialization_key => 'tome'
          end # let

          it { expect(instance.plural_serialization_key).to be == :tome }
        end # context

        context 'when options[:plural_serialization_key] is a singular symbol' \
        do
          let(:resource_options) do
            super().merge :plural_serialization_key => :tome
          end # let

          it { expect(instance.plural_serialization_key).to be == :tome }
        end # context

        context 'when options[:plural_serialization_key] is ' \
                'an ambiguous string' do
          let(:resource_options) do
            super().merge :plural_serialization_key => 'data'
          end # let

          it { expect(instance.plural_serialization_key).to be == :data }
        end # context

        context 'when options[:plural_serialization_key] is ' \
                'an ambiguous symbol' do
          let(:resource_options) do
            super().merge :plural_serialization_key => :data
          end # let

          it { expect(instance.plural_serialization_key).to be == :data }
        end # context

        context 'when options[:resource_name] is set' do
          let(:resource_options) { super().merge :resource_name => 'tome' }

          it { expect(instance.plural_serialization_key).to be == :tomes }
        end # context

        context 'when options[:serialization_key] is set' do
          let(:resource_options) { super().merge :serialization_key => :tome }

          it { expect(instance.plural_serialization_key).to be == :tomes }
        end # context

        wrap_context 'when the resource class has a compound name' do
          it 'should return the resource key' do
            expect(instance.plural_serialization_key).
              to be == :archived_periodicals
          end # it
        end # wrap_context
      end # describe

      describe '#primary_key' do
        include_examples 'should have reader', :primary_key, :book_id

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

      describe '#resource_key' do
        include_examples 'should have reader', :resource_key, :book

        it 'should alias the method' do
          expect(instance).
            to alias_method(:resource_key).
            as(:singular_resource_key)
        end # it

        context 'when options[:resource_name] is set' do
          let(:resource_options) { super().merge :resource_name => 'tome' }

          it { expect(instance.resource_key).to be == :tome }
        end # context

        wrap_context 'when the resource class has a compound name' do
          it 'should return the resource key' do
            expect(instance.resource_key).to be == :archived_periodical
          end # it
        end # wrap_context
      end # describe

      describe '#resource_name' do
        include_examples 'should have reader',
          :resource_name,
          ->() { be == 'book' }

        it 'should alias the method' do
          expect(instance).
            to alias_method(:resource_name).
            as(:singular_resource_name)
        end # it

        context 'when options[:resource_name] is a plural string' do
          let(:resource_options) { super().merge :resource_name => 'tomes' }

          it { expect(instance.resource_name).to be == 'tome' }
        end # context

        context 'when options[:resource_name] is a plural symbol' do
          let(:resource_options) { super().merge :resource_name => :tomes }

          it { expect(instance.resource_name).to be == 'tome' }
        end # context

        context 'when options[:resource_name] is a singular string' do
          let(:resource_options) { super().merge :resource_name => 'tome' }

          it { expect(instance.resource_name).to be == 'tome' }
        end # context

        context 'when options[:resource_name] is a singular symbol' do
          let(:resource_options) { super().merge :resource_name => :tome }

          it { expect(instance.resource_name).to be == 'tome' }
        end # context

        wrap_context 'when the resource class has a compound name' do
          it 'should return the resource name' do
            expect(instance.resource_name).to be == 'archived_periodical'
          end # it
        end # wrap_context
      end # describe

      describe '#resource_name_changed?' do
        include_examples 'should have predicate', :resource_name_changed?, false

        context 'when options[:plural_resource_name] is set' do
          let(:resource_options) do
            super().merge :plural_resource_name => 'tomes'
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

      describe '#serialization_key' do
        include_examples 'should have reader',
          :serialization_key,
          ->() { be == :book }

        it 'should alias the method' do
          expect(instance).
            to alias_method(:serialization_key).
            as(:singular_serialization_key)
        end # it

        context 'when options[:resource_name] is set' do
          let(:resource_options) { super().merge :resource_name => 'tomes' }

          it { expect(instance.serialization_key).to be == :tome }
        end # context

        context 'when options[:serialization_key] is a plural string' do
          let(:resource_options) do
            super().merge :serialization_key => 'tomes'
          end # let

          it { expect(instance.serialization_key).to be == :tome }
        end # context

        context 'when options[:serialization_key] is a plural symbol' do
          let(:resource_options) do
            super().merge :serialization_key => :tomes
          end # let

          it { expect(instance.serialization_key).to be == :tome }
        end # context

        context 'when options[:serialization_key] is a singular string' do
          let(:resource_options) do
            super().merge :serialization_key => 'tome'
          end # let

          it { expect(instance.serialization_key).to be == :tome }
        end # context

        context 'when options[:serialization_key] is a singular symbol' do
          let(:resource_options) do
            super().merge :serialization_key => :tome
          end # let

          it { expect(instance.serialization_key).to be == :tome }
        end # context

        wrap_context 'when the resource class has a compound name' do
          it 'should return the resource name' do
            expect(instance.serialization_key).to be == :archived_periodical
          end # it
        end # wrap_context
      end # describe

      describe '#serialization_key_changed?' do
        include_examples 'should have predicate',
          :serialization_key_changed?,
          false

        context 'when options[:plural_resource_name] is set' do
          let(:resource_options) do
            super().merge :plural_resource_name => 'tomes'
          end # let

          it { expect(instance.serialization_key_changed?).to be true }
        end # context

        context 'when options[:plural_serialization_key] is set' do
          let(:resource_options) do
            super().merge :plural_serialization_key => :tomes
          end # let

          it { expect(instance.serialization_key_changed?).to be true }
        end # context

        context 'when options[:resource_name] is set' do
          let(:resource_options) { super().merge :resource_name => 'tome' }

          it { expect(instance.serialization_key_changed?).to be true }
        end # context

        context 'when options[:serialization_key] is set' do
          let(:resource_options) { super().merge :serialization_key => :tome }

          it { expect(instance.serialization_key_changed?).to be true }
        end # context

        wrap_context 'when the resource class has a compound name' do
          it { expect(instance.serialization_key_changed?).to be false }
        end # wrap_context
      end # describe
    end # shared_examples
  end # module
end # module
