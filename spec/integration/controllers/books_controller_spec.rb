# spec/integration/controllers/books_controller_spec.rb

require 'rails_helper'

require 'integration/controllers/controller_examples'

RSpec.describe BooksController, :type => :controller do
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

  shared_examples 'should require a book id' do
    describe 'when the book id is invalid' do
      let(:book_id) { Spec::Book.new.id }

      include_examples 'should redirect to',
        ->() { books_path },
        :as => 'books_path'

      it 'should set the flash' do
        perform_action

        expect(controller.flash[:warning]).to include 'Unable to find book.'
      end # it
    end # describe
  end # shared_examples

  let(:books_collection) do
    transform =
      Bronze::Entities::Transforms::EntityTransform.new(Spec::Book)

    controller.send(:repository).collection(Spec::Book, transform)
  end # let

  let(:params)  { {} }
  let(:headers) { {} }

  describe '#create' do
    let(:attributes) { {} }
    let(:params)     { super().merge :book => attributes }

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
      let(:expected_errors) { { 'book[title]' => ['must be present'] } }

      include_examples 'should render template',
        'books/new',
        { :status => :unprocessable_entity },
        lambda { |options|
          book = options[:locals][:book]
          book_attributes = book.attributes.tap { |hsh| hsh.delete :id }

          expect(book).to be_a Spec::Book
          expect(book_attributes).to be == expected_attributes

          errors = options[:locals][:errors]
          expect(errors).to be == expected_errors
        } # end include_examples

      it 'should set the flash' do
        perform_action

        expect(controller.flash.now[:warning]).
          to include 'Unable to create book.'
      end # it

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
        ->() { book_path(created_book) },
        :as => 'book_path'

      it 'should create the book' do
        expect { perform_action }.to change(books_collection, :count).by(1)

        attributes.each do |attr_name, value|
          expect(created_book.send attr_name).to be == value
        end # each
      end # it

      it 'should set the flash' do
        perform_action

        expect(controller.flash[:success]).
          to include 'Successfully created book.'
      end # it
    end # describe
  end # describe

  describe '#destroy' do
    include_context 'when the collection has many books'

    let(:book)    { books_collection.to_a.first }
    let(:book_id) { book.id }
    let(:params)  { super().merge :id => book_id }

    def perform_action
      delete :destroy, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should require a book id'

    it 'should destroy the book' do
      expect { perform_action }.to change(books_collection, :count).by(-1)

      expect(books_collection.find book.id).to be nil
    end # it

    it 'should set the flash' do
      perform_action

      expect(controller.flash[:danger]).
        to include 'Successfully destroyed book.'
    end # it
  end # describe

  describe '#edit' do
    include_context 'when the collection has many books'

    let(:book)    { books_collection.to_a.first }
    let(:book_id) { book.id }
    let(:params)  { super().merge :id => book_id }

    def perform_action
      get :edit, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should require a book id'

    include_examples 'should render template',
      'books/edit',
      lambda { |options|
        found_book = options[:locals][:book]

        expect(found_book).to be == book
      } # end include_examples

    it 'should not set the flash' do
      perform_action

      expect(controller.flash).to be_empty
    end # it
  end # describe

  describe '#index' do
    def perform_action
      get :index, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should render template',
      'books/index',
      lambda { |options|
        matching_books = options[:locals][:books]

        expect(matching_books).to be_a Array
        expect(matching_books.empty?).to be true
      } # end include_examples

    it 'should not set the flash' do
      perform_action

      expect(controller.flash).to be_empty
    end # it

    wrap_context 'when the collection has many books' do
      include_examples 'should render template',
        'books/index',
        lambda { |options|
          matching_books = options[:locals][:books]

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
          'books/index',
          lambda { |options|
            matching_books = options[:locals][:books]

            expect(matching_books).to contain_exactly(*expected)
          } # end include_examples
      end # describe
    end # wrap_context
  end # describe

  describe '#new' do
    let(:attributes) { {} }
    let(:params)     { super().merge :book => attributes }
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
      'books/new',
      lambda { |options|
        book = options[:locals][:book]
        book_attributes = book.attributes.tap { |hsh| hsh.delete :id }

        expect(book).to be_a Spec::Book
        expect(book_attributes).to be == expected_attributes
      } # end include_examples

    it 'should not set the flash' do
      perform_action

      expect(controller.flash).to be_empty
    end # it
  end # describe

  describe '#show' do
    include_context 'when the collection has many books'

    let(:book)    { books_collection.to_a.first }
    let(:book_id) { book.id }
    let(:params)  { super().merge :id => book_id }

    def perform_action
      get :show, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should require a book id'

    include_examples 'should render template',
      'books/show',
      lambda { |options|
        found_book = options[:locals][:book]

        expect(found_book).to be == book
      } # end include_examples

    it 'should not set the flash' do
      perform_action

      expect(controller.flash).to be_empty
    end # it
  end # describe

  describe '#update' do
    include_context 'when the collection has many books'

    let(:book)    { books_collection.to_a.first }
    let(:book_id) { book.id }
    let(:params)  { super().merge :id => book_id, :book => update_attributes }
    let(:update_attributes) do
      {}
    end # let

    def perform_action
      patch :update, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should require a book id'

    describe 'with invalid attributes' do
      let(:update_attributes) do
        { :title => '' }
      end # let
      let(:expected_attributes) do
        book.attributes.merge(update_attributes).tap { |hsh| hsh.delete :id }
      end # let
      let(:expected_errors) { { 'book[title]' => ['must be present'] } }

      include_examples 'should render template',
        'books/edit',
        { :status => :unprocessable_entity },
        lambda { |options|
          changed_book = options[:locals][:book]
          book_attributes = changed_book.attributes.tap { |hsh| hsh.delete :id }

          expect(changed_book).to be_a Spec::Book
          expect(book_attributes).to be == expected_attributes

          errors = options[:locals][:errors]
          expect(errors).to be == expected_errors
        } # end include_examples

      it 'should not update the book' do
        expect { perform_action }.
          not_to change { books_collection.find(book.id).attributes }
      end # it

      it 'should set the flash' do
        perform_action

        expect(controller.flash.now[:warning]).
          to include 'Unable to update book.'
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
        book.attributes.merge(update_attributes)
      end # let

      include_examples 'should redirect to',
        ->() { book_path(book) },
        :as => 'book_path'

      it 'should update the book' do
        expect { perform_action }.
          to change { books_collection.find(book.id).attributes }.
          to be == expected_attributes
      end # it

      it 'should set the flash' do
        perform_action

        expect(controller.flash[:success]).
          to include 'Successfully updated book.'
      end # it
    end # describe
  end # describe
end # describe
