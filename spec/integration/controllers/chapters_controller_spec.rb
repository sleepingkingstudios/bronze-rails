# spec/integration/controllers/chapters_controller_spec.rb

require 'rails_helper'

require 'integration/controllers/controller_examples'

RSpec.describe ChaptersController, :type => :controller do
  include Spec::Examples::Integration::ControllerExamples

  shared_context 'when the collection has many books' do
    let(:attributes) do
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
      attributes.map do |hsh|
        book = Spec::Book.new hsh

        books_collection.insert book

        book
      end # each
    end # let
  end # shared_context

  shared_context 'when the collection has many chapters' do
    include_context 'when the collection has many books'

    let(:attributes) do
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
        attributes.map do |hsh|
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

  let(:books_collection) do
    transform =
      Bronze::Entities::Transforms::EntityTransform.new(Spec::Book)

    controller.send(:repository).collection(:books, transform)
  end # let
  let(:chapters_collection) do
    transform =
      Bronze::Entities::Transforms::EntityTransform.new(Spec::Chapter)

    controller.send(:repository).collection(:chapters, transform)
  end # let

  let(:params)  { {} }
  let(:headers) { {} }

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
        } # end include_examples
    end # wrap_context
  end # describe
end # describe
