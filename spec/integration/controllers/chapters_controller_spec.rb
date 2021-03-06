# spec/integration/controllers/chapters_controller_spec.rb

require 'rails_helper'

require 'integration/controllers/controller_examples'

RSpec.describe ChaptersController, :type => :controller do
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

  shared_context 'when the collection has many chapters' do
    include_context 'when the collection has many books'

    let(:chapters_attributes) do
      [
        {
          :title      => 'Chapter 1',
          :word_count => 1_028
        }, # end chapter
        {
          :title      => 'Chapter 2',
          :word_count => 768
        }, # end chapter
        {
          :title      => 'Chapter 3',
          :word_count => 1_280
        } # end chapter
      ] # end titles
    end # let
    let!(:chapters) do
      books.map do |book|
        chapters_attributes.map do |hsh|
          chapter = Spec::Chapter.new hsh.merge(:book => book)

          chapters_collection.insert chapter

          chapter
        end # each
      end. # map
        flatten
    end # let
  end # shared_context

  shared_examples 'should require a book id' do
    describe 'when the book id is invalid' do
      let(:book_id) { Spec::Book.new.id }

      include_examples 'should redirect to',
        ->() { books_path },
        :as => 'books_path'
    end # describe
  end # shared_examples

  shared_examples 'should require a chapter id' do
    describe 'when the chapter id is invalid' do
      let(:chapter_id) { Spec::Chapter.new.id }

      include_examples 'should redirect to',
        ->() { book_chapters_path(book) },
        :as => 'book_chapters_path'
    end # describe
  end # shared_examples

  let(:books_collection) do
    transform =
      Bronze::Entities::Transforms::EntityTransform.new(Spec::Book)

    controller.send(:repository).collection(Spec::Book, transform)
  end # let
  let(:chapters_collection) do
    transform =
      Bronze::Entities::Transforms::EntityTransform.new(Spec::Chapter)

    controller.send(:repository).collection(Spec::Chapter, transform)
  end # let

  let(:params)  { {} }
  let(:headers) { {} }

  describe '#create' do
    include_context 'when the collection has many books'

    let(:book)       { books.first }
    let(:book_id)    { book.id }
    let(:attributes) { {} }
    let(:params) do
      super().merge :book_id => book_id, :chapter => attributes
    end # let

    def perform_action
      post :create, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should require a book id'

    describe 'with invalid attributes' do
      let(:attributes) { { :word_count => 512 } }
      let(:expected_attributes) do
        hsh = {}

        Spec::Chapter.attributes.keys.each do |attr_name|
          next if attr_name == :id

          hsh[attr_name] = attributes[attr_name]
        end # each

        hsh[:book_id] = book.id

        hsh
      end # let
      let(:expected_errors) { { 'chapter[title]' => ['must be present'] } }

      include_examples 'should render template',
        'chapters/new',
        { :status => :unprocessable_entity },
        lambda { |options|
          expect(options[:locals][:book]).to be == book

          chapter = options[:locals][:chapter]
          chapter_attributes = chapter.attributes.tap { |hsh| hsh.delete :id }

          expect(chapter).to be_a Spec::Chapter
          expect(chapter.book).to be == book
          expect(chapter_attributes).to be == expected_attributes

          errors = options[:locals][:errors]
          expect(errors).to be == expected_errors
        } # end include_examples

      it 'should not create a chapter' do
        expect { perform_action }.not_to change(chapters_collection, :count)
      end # it
    end # describe

    describe 'with valid attributes' do
      let(:attributes) do
        {
          :title      => 'An Unexpected Party',
          :word_count => 512
        } # attributes
      end # let
      let(:created_chapter) { chapters_collection.matching(attributes).one }

      include_examples 'should redirect to',
        ->() { book_chapter_path(book, created_chapter) },
        :as => 'book_chapter_path'

      it 'should create the chapter' do
        expect { perform_action }.to change(chapters_collection, :count).by(1)

        expect(created_chapter.book_id).to be == book.id

        attributes.each do |attr_name, value|
          expect(created_chapter.send attr_name).to be == value
        end # each
      end # it
    end # describe
  end # describe

  describe '#destroy' do
    include_context 'when the collection has many chapters'

    let(:book)       { books_collection.to_a.first }
    let(:book_id)    { book.id }
    let(:chapter) do
      chapters_collection.matching(:book_id => book.id).to_a.first
    end # let
    let(:chapter_id) { chapter.id }
    let(:params)     { super().merge :book_id => book_id, :id => chapter_id }

    def perform_action
      delete :destroy, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should require a book id'

    include_examples 'should require a chapter id'

    it 'should destroy the book' do
      expect { perform_action }.to change(chapters_collection, :count).by(-1)

      expect(chapters_collection.find chapter.id).to be nil
    end # it
  end # describe

  describe '#edit' do
    include_context 'when the collection has many chapters'

    let(:book)       { books_collection.to_a.first }
    let(:book_id)    { book.id }
    let(:chapter) do
      chapters_collection.matching(:book_id => book.id).to_a.first
    end # let
    let(:chapter_id) { chapter.id }
    let(:params)     { super().merge :book_id => book_id, :id => chapter_id }

    def perform_action
      get :edit, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should require a book id'

    include_examples 'should require a chapter id'

    include_examples 'should render template',
      'chapters/edit',
      lambda { |options|
        expect(options[:locals][:book]).to be == book

        found_chapter = options[:locals][:chapter]

        expect(found_chapter).to be == chapter
        expect(found_chapter.book).to be == book
      } # end include_examples
  end # describe

  describe '#index' do
    include_context 'when the collection has many books'

    let(:book)    { books.first }
    let(:book_id) { book.id }
    let(:params)  { super().merge :book_id => book_id }

    def perform_action
      get :index, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should require a book id'

    include_examples 'should render template',
      'chapters/index',
      lambda { |options|
        expect(options[:locals][:book]).to be == book

        matching_chapters = options[:locals][:chapters]

        expect(matching_chapters).to be_a Array
        expect(matching_chapters.empty?).to be true
      } # end include_examples

    wrap_context 'when the collection has many chapters' do
      let(:expected) do
        chapters.select { |chapter| chapter.book_id == book_id }
      end # let

      include_examples 'should render template',
        'chapters/index',
        lambda { |options|
          expect(options[:locals][:book]).to be == book

          matching_chapters = options[:locals][:chapters]

          expect(matching_chapters).to be_a Array
          expect(matching_chapters).to contain_exactly(*expected)

          matching_chapters.each do |matching_chapter|
            expect(matching_chapter.book).to be == book
          end # each
        } # end include_examples
    end # wrap_context
  end # describe

  describe '#new' do
    include_context 'when the collection has many books'

    let(:book)       { books.first }
    let(:book_id)    { book.id }
    let(:attributes) { {} }
    let(:params) do
      super().merge :book_id => book_id, :chapter => attributes
    end # let
    let(:expected_attributes) do
      hsh = {}

      Spec::Chapter.attributes.keys.each do |attr_name|
        next if attr_name == :id

        hsh[attr_name] = nil
      end # each

      hsh[:book_id] = book.id

      hsh
    end # let

    def perform_action
      get :new, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should require a book id'

    include_examples 'should render template',
      'chapters/new',
      lambda { |options|
        expect(options[:locals][:book]).to be == book

        chapter = options[:locals][:chapter]
        chapter_attributes = chapter.attributes.tap { |hsh| hsh.delete :id }

        expect(chapter).to be_a Spec::Chapter
        expect(chapter.book).to be == book
        expect(chapter_attributes).to be == expected_attributes
      } # end include_examples
  end # describe

  describe '#show' do
    include_context 'when the collection has many chapters'

    let(:book)       { books_collection.to_a.first }
    let(:book_id)    { book.id }
    let(:chapter) do
      chapters_collection.matching(:book_id => book.id).to_a.first
    end # let
    let(:chapter_id) { chapter.id }
    let(:params)     { super().merge :book_id => book_id, :id => chapter_id }

    def perform_action
      get :show, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should require a book id'

    include_examples 'should require a chapter id'

    include_examples 'should render template',
      'chapters/show',
      lambda { |options|
        expect(options[:locals][:book]).to be == book

        found_chapter = options[:locals][:chapter]

        expect(found_chapter).to be == chapter
        expect(found_chapter.book).to be == book
      } # end include_examples
  end # describe

  describe '#update' do
    include_context 'when the collection has many chapters'

    let(:book)       { books_collection.to_a.first }
    let(:book_id)    { book.id }
    let(:chapter) do
      chapters_collection.matching(:book_id => book.id).to_a.first
    end # let
    let(:chapter_id) { chapter.id }
    let(:params) do
      super().merge(
        :book_id => book_id,
        :id      => chapter_id,
        :chapter => update_attributes
      ) # end params
    end # let
    let(:update_attributes) do
      {}
    end # let

    def perform_action
      patch :update, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should require a book id'

    include_examples 'should require a chapter id'

    describe 'with invalid attributes' do
      let(:update_attributes) do
        { :title => '' }
      end # let
      let(:expected_attributes) do
        chapter.attributes.merge(update_attributes).tap { |hsh| hsh.delete :id }
      end # let
      let(:expected_errors) { { 'chapter[title]' => ['must be present'] } }

      include_examples 'should render template',
        'chapters/edit',
        { :status => :unprocessable_entity },
        lambda { |options|
          expect(options[:locals][:book]).to be == book

          changed_chapter = options[:locals][:chapter]
          chapter_attributes =
            changed_chapter.attributes.tap { |hsh| hsh.delete :id }

          expect(changed_chapter).to be_a Spec::Chapter
          expect(changed_chapter.book).to be == book
          expect(chapter_attributes).to be == expected_attributes

          errors = options[:locals][:errors]
          expect(errors).to be == expected_errors
        } # end include_examples

      it 'should not update the chapter' do
        expect { perform_action }.
          not_to change { chapters_collection.find(chapter.id).attributes }
      end # it
    end # describe

    describe 'with valid attributes' do
      let(:update_attributes) do
        {
          :title      => 'An Unexpected Party',
          :word_count => 512
        } # attributes
      end # let
      let(:expected_attributes) do
        chapter.attributes.merge(update_attributes)
      end # let

      include_examples 'should redirect to',
        ->() { book_chapter_path(book, chapter) },
        :as => 'book_chapter_path'

      it 'should update the chapter' do
        expect { perform_action }.
          to change { chapters_collection.find(chapter.id).attributes }.
          to be == expected_attributes
      end # it
    end # describe
  end # describe
end # describe
