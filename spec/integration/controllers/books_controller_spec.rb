# spec/integration/controllers/books_controller_spec.rb

require 'rails_helper'

require 'integration/controllers/controller_examples'

RSpec.describe BooksController, :type => :controller do
  include Spec::Examples::Integration::ControllerExamples

  shared_context 'when the collection has many books' do
    let(:repository) { controller.send :repository }
    let(:books_collection) do
      transform =
        Bronze::Entities::Transforms::EntityTransform.new(Spec::Book)

      repository.collection(:books, transform)
    end # let
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
      attributes.map do |hsh|
        book = Spec::Book.new hsh

        books_collection.insert book

        book
      end # each
    end # let
  end # shared_context

  let(:params)  { {} }
  let(:headers) { {} }

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
end # describe
