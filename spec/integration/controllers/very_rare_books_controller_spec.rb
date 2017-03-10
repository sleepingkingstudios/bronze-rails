# spec/integration/controllers/very_rare_books_controller_spec.rb

require 'rails_helper'

require 'integration/controllers/controller_examples'

RSpec.describe VeryRareBooksController, :type => :controller do
  include Spec::Examples::Integration::ControllerExamples

  shared_context 'when the collection has many books' do
    let(:books_attributes) do
      [
        {
          :title  => 'The Fellowship of the Ring',
          :series => 'The Lord of the Rings'
        }, # end book
        {
          :title  => 'The Two Towers',
          :series => 'The Lord of the Rings'
        }, # end book
        {
          :title  => 'The Return of the King',
          :series => 'The Lord of the Rings'
        }, # end book
        {
          :title  => 'A Princess of Mars',
          :series => 'Barsoom'
        }, # end book
        {
          :title  => 'The Gods of Mars',
          :series => 'Barsoom'
        }, # end book
        {
          :title  => 'The Warlord of Mars',
          :series => 'Barsoom'
        } # end book
      ] # end titles
    end # let
    let!(:books) do
      books_attributes.map do |hsh|
        book = Spec::Book.new hsh

        books_collection.insert book

        book
      end # each
    end # let
  end # shared_context

  shared_examples 'should require a rare_book id' do
    describe 'when the book id is invalid' do
      let(:rare_book_id) { Spec::Book.new.id }

      include_examples 'should redirect to',
        ->() { rare_books_path },
        :as => 'rare_books_path'
    end # describe
  end # shared_examples

  let(:books_collection) do
    transform =
      Bronze::Entities::Transforms::EntityTransform.new(Spec::Book)

    controller.send(:repository).collection(:books, transform)
  end # let

  let(:params)  { {} }
  let(:headers) { {} }

  describe '#create' do
    let(:attributes) { {} }
    let(:params)     { super().merge :rare_book => attributes }

    def perform_action
      post :create, :headers => headers, :params => params
    end # method perform_action

    describe 'with invalid attributes' do
      let(:attributes) do
        { :series => 'The Lord of the Rings' }
      end # let
      let(:expected_attributes) do
        hsh = {}

        Spec::Book.attributes.keys.each do |attr_name|
          next if attr_name == :id

          hsh[attr_name] = attributes[attr_name]
        end # each

        hsh
      end # let
      let(:expected_error) do
        Bronze::Errors::Error.new(
          [:book, :title],
          Bronze::Constraints::PresenceConstraint::EMPTY_ERROR,
          {}
        ) # end error
      end # let

      include_examples 'should render template',
        'very_rare_books/new',
        { :status => :unprocessable_entity },
        lambda { |options|
          book = options[:locals][:first_edition]
          book_attributes = book.attributes.tap { |hsh| hsh.delete :id }

          expect(book).to be_a Spec::Book
          expect(book_attributes).to be == expected_attributes

          errors = options[:locals][:errors]
          expect(errors).to be_a Bronze::Errors::Errors
          expect(errors[:book][:title]).to include expected_error
        } # end include_examples

      it 'should not create a book' do
        expect { perform_action }.not_to change(books_collection, :count)
      end # it
    end # describe

    describe 'with valid attributes' do
      let(:attributes) do
        {
          :title      => 'The Hobbit',
          :series     => 'The Lord of the Rings',
          :page_count => 320
        } # attributes
      end # let
      let(:created_book) { books_collection.matching(attributes).one }

      include_examples 'should redirect to',
        ->() { rare_book_path(created_book) },
        :as => 'rare_book_path'

      it 'should create the book' do
        expect { perform_action }.to change(books_collection, :count).by(1)

        attributes.each do |attr_name, value|
          expect(created_book.send attr_name).to be == value
        end # each
      end # it
    end # describe
  end # describe

  describe '#destroy' do
    include_context 'when the collection has many books'

    let(:rare_book)    { books_collection.to_a.first }
    let(:rare_book_id) { rare_book.id }
    let(:params)       { super().merge :id => rare_book_id }

    def perform_action
      delete :destroy, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should require a rare_book id'

    it 'should destroy the book' do
      expect { perform_action }.to change(books_collection, :count).by(-1)

      expect(books_collection.find rare_book.id).to be nil
    end # it
  end # describe

  describe '#edit' do
    include_context 'when the collection has many books'

    let(:rare_book)    { books_collection.to_a.first }
    let(:rare_book_id) { rare_book.id }
    let(:params)       { super().merge :id => rare_book_id }

    def perform_action
      get :edit, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should require a rare_book id'

    include_examples 'should render template',
      'very_rare_books/edit',
      lambda { |options|
        found_book = options[:locals][:first_edition]

        expect(found_book).to be == rare_book
      } # end include_examples
  end # describe

  describe '#index' do
    def perform_action
      get :index, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should render template',
      'very_rare_books/index',
      lambda { |options|
        matching_books = options[:locals][:first_editions]

        expect(matching_books).to be_a Array
        expect(matching_books.empty?).to be true
      } # end include_examples

    wrap_context 'when the collection has many books' do
      include_examples 'should render template',
        'very_rare_books/index',
        lambda { |options|
          matching_books = options[:locals][:first_editions]

          expect(matching_books).to contain_exactly(*books)
        } # end include_examples

      describe 'with params[:matching] => :series' do
        let(:params) do
          super().merge :matching => { :series => 'Barsoom' }
        end # let
        let(:expected) do
          books.select { |book| book.series == 'Barsoom' }
        end # let

        include_examples 'should render template',
          'very_rare_books/index',
          lambda { |options|
            matching_books = options[:locals][:first_editions]

            expect(matching_books).to contain_exactly(*expected)
          } # end include_examples
      end # describe
    end # wrap_context
  end # describe

  describe '#new' do
    let(:attributes) { {} }
    let(:params)     { super().merge :rare_book => attributes }
    let(:expected_attributes) do
      hsh = {}

      Spec::Book.attributes.keys.each do |attr_name|
        next if attr_name == :id

        hsh[attr_name] = nil
      end # each

      hsh
    end # let

    def perform_action
      get :new, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should render template',
      'very_rare_books/new',
      lambda { |options|
        book = options[:locals][:first_edition]
        book_attributes = book.attributes.tap { |hsh| hsh.delete :id }

        expect(book).to be_a Spec::Book
        expect(book_attributes).to be == expected_attributes
      } # end include_examples
  end # describe

  describe '#show' do
    include_context 'when the collection has many books'

    let(:rare_book)    { books_collection.to_a.first }
    let(:rare_book_id) { rare_book.id }
    let(:params)       { super().merge :id => rare_book_id }

    def perform_action
      get :show, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should require a rare_book id'

    include_examples 'should render template',
      'very_rare_books/show',
      lambda { |options|
        found_book = options[:locals][:first_edition]

        expect(found_book).to be == rare_book
      } # end include_examples
  end # describe

  describe '#update' do
    include_context 'when the collection has many books'

    let(:rare_book)    { books_collection.to_a.first }
    let(:rare_book_id) { rare_book.id }
    let(:params) do
      super().merge :id => rare_book_id, :rare_book => update_attributes
    end # let
    let(:update_attributes) do
      {}
    end # let

    def perform_action
      patch :update, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should require a rare_book id'

    describe 'with invalid attributes' do
      let(:update_attributes) do
        { :title => '' }
      end # let
      let(:expected_attributes) do
        rare_book.attributes.
          merge(update_attributes).
          tap { |hsh| hsh.delete :id }
      end # let
      let(:expected_error) do
        Bronze::Errors::Error.new(
          [:book, :title],
          Bronze::Constraints::PresenceConstraint::EMPTY_ERROR,
          {}
        ) # end error
      end # let

      include_examples 'should render template',
        'very_rare_books/edit',
        { :status => :unprocessable_entity },
        lambda { |options|
          changed_book = options[:locals][:first_edition]
          book_attributes = changed_book.attributes.tap { |hsh| hsh.delete :id }

          expect(changed_book).to be_a Spec::Book
          expect(book_attributes).to be == expected_attributes

          errors = options[:locals][:errors]
          expect(errors).to be_a Bronze::Errors::Errors
          expect(errors[:book][:title]).to include expected_error
        } # end include_examples

      it 'should not update the book' do
        expect { perform_action }.
          not_to change { books_collection.find(rare_book.id).attributes }
      end # it
    end # describe

    describe 'with valid attributes' do
      let(:update_attributes) do
        {
          :title      => 'The Hobbit',
          :series     => 'The Lord of the Rings',
          :page_count => 320
        } # attributes
      end # let
      let(:expected_attributes) do
        rare_book.attributes.merge(update_attributes)
      end # let

      include_examples 'should redirect to',
        ->() { rare_book_path(rare_book) },
        :as => 'rare_book_path'

      it 'should update the book' do
        expect { perform_action }.
          to change { books_collection.find(rare_book.id).attributes }.
          to be == expected_attributes
      end # it
    end # describe
  end # describe
end # describe
