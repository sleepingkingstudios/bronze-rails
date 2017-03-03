# spec/bronze/rails/services/routes_service_spec.rb

require 'rails_helper'

require 'bronze/rails/services/routes_service'

require 'fixtures/entities/book'
require 'fixtures/entities/chapter'
require 'fixtures/entities/section'

RSpec.describe Bronze::Rails::Services::RoutesService do
  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '::instance' do
    it { expect(described_class).to respond_to(:instance).with(0).arguments }

    it 'should return a cached instance' do
      instance = described_class.instance

      expect(instance).to be_a described_class
      expect(instance).to be described_class.instance
    end # it
  end # describe

  describe 'route helpers' do
    let(:book)    { Spec::Book.new }
    let(:chapter) { Spec::Chapter.new }
    let(:section) { Spec::Section.new }

    describe '#books_path' do
      it { expect(instance.books_path).to be == '/books' }
    end # describe

    describe '#new_book_path' do
      it { expect(instance.new_book_path).to be == '/books/new' }
    end # describe

    describe '#book_path' do
      it { expect(instance.book_path book.id).to be == "/books/#{book.id}" }
    end # describe

    describe '#edit_book_path' do
      it 'should return the path' do
        expect(instance.edit_book_path book.id).
          to be == "/books/#{book.id}/edit"
      end # it
    end # describe

    describe '#book_chapter_sections_path' do
      let(:params) { [book.id, chapter.id] }
      let(:expected) do
        "/books/#{book.id}/chapters/#{chapter.id}/sections"
      end # let

      it 'should return the path' do
        expect(instance.book_chapter_sections_path(*params)).to be == expected
      end # it
    end # describe

    describe '#book_chapter_section_path' do
      let(:params) { [book.id, chapter.id, section.id] }
      let(:expected) do
        "/books/#{book.id}/chapters/#{chapter.id}/sections/#{section.id}"
      end # let

      it 'should return the path' do
        expect(instance.book_chapter_section_path(*params)).to be == expected
      end # it
    end # describe
  end # describe
end # describe
