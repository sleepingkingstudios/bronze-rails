# spec/bronze/rails/services/i18n_service_spec.rb

require 'rails_helper'

require 'bronze/rails/services/i18n_service'

RSpec.describe Bronze::Rails::Services::I18nService do
  shared_context 'when a default locale is set' do
    let(:default_locale) { 'en-GB' }
  end # shared_context

  let(:default_locale) { nil }
  let(:instance)       { described_class.new default_locale }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end # describe

  describe '::instance' do
    it { expect(described_class).to respond_to(:instance).with(0).arguments }

    it 'should return a cached instance' do
      instance = described_class.instance

      expect(instance).to be_a described_class
      expect(instance).to be described_class.instance
    end # it
  end # describe

  describe '#default_locale' do
    before(:example) do
      allow(I18n).to receive(:default_locale).and_return('en-US')
    end # before example

    include_examples 'should have reader', :default_locale, 'en-US'

    wrap_context 'when a default locale is set' do
      it { expect(instance.default_locale).to be == default_locale }
    end # wrap_context
  end # describe

  describe '#translate' do
    let(:key) { 'scope.inner_scope.key' }

    it { expect(instance).to respond_to(:translate).with(1..2).arguments }

    it 'should delegate to I18n' do
      expect(I18n).to receive(:translate).
        with(key, :locale => I18n.default_locale).
        and_return('translated')

      expect(instance.translate key).to be == 'translated'
    end # it

    describe 'with a locale' do
      let(:locale) { 'fr-FR' }

      it 'should delegate to I18n' do
        expect(I18n).to receive(:translate).
          with(key, :locale => locale).
          and_return('traduit')

        expect(instance.translate key, :locale => locale).to be == 'traduit'
      end # it
    end # describe

    describe 'with interpolation variables' do
      let(:options)  { { :ichi => 1, :ni => 2, :san => 3 } }
      let(:expected) { options.merge :locale => I18n.default_locale }

      it 'should delegate to I18n' do
        expect(I18n).to receive(:translate).
          with(key, expected).
          and_return('translated')

        expect(instance.translate key, options).to be == 'translated'
      end # it
    end # describe

    wrap_context 'when a default locale is set' do
      it 'should delegate to I18n' do
        expect(I18n).to receive(:translate).
          with(key, :locale => default_locale).
          and_return('translated')

        expect(instance.translate key).to be == 'translated'
      end # it

      describe 'with a locale' do
        let(:locale) { 'fr-FR' }

        it 'should delegate to I18n' do
          expect(I18n).to receive(:translate).
            with(key, :locale => locale).
            and_return('traduit')

          expect(instance.translate key, :locale => locale).to be == 'traduit'
        end # it
      end # describe

      describe 'with interpolation variables' do
        let(:options)  { { :ichi => 1, :ni => 2, :san => 3 } }
        let(:expected) { options.merge :locale => default_locale }

        it 'should delegate to I18n' do
          expect(I18n).to receive(:translate).
            with(key, expected).
            and_return('translated')

          expect(instance.translate key, options).to be == 'translated'
        end # it
      end # describe
    end # wrap_context
  end # describe

  describe '#translate_with_fallbacks' do
    let(:fallbacks) do
      {
        'numbers.one'   => { :ichi => 1 },
        'numbers.two'   => { :ni   => 2 },
        'numbers.three' => { :san  => 3 }
      } # end fallbacks
    end # let

    it 'should define the method' do
      expect(instance).
        to respond_to(:translate_with_fallbacks).
        with(1..2).arguments
    end # it

    context 'when a translation is defined for the first item' do
      it 'should delegate to I18n' do
        expect(I18n).to receive(:exists?).
          with(fallbacks.keys[0], I18n.default_locale).
          and_return(true)

        expect(I18n).
          to receive(:translate).
          with('numbers.one', :ichi => 1).
          and_return('translated')

        expect(instance.translate_with_fallbacks fallbacks).
          to be == 'translated'
      end # it

      describe 'when a locale is set' do
        let(:locale) { 'fr-FR' }

        it 'should delegate to I18n' do
          expect(I18n).to receive(:exists?).
            with(fallbacks.keys[0], locale).
            and_return(true)

          expect(I18n).
            to receive(:translate).
            with('numbers.one', :ichi => 1).
            and_return('translated')

          expect(instance.translate_with_fallbacks fallbacks, locale).
            to be == 'translated'
        end # it
      end # describe
    end # context

    context 'when a translation is defined for the second item' do
      it 'should delegate to I18n' do
        expect(I18n).to receive(:exists?).
          with(fallbacks.keys[0], I18n.default_locale).
          and_return(false)

        expect(I18n).to receive(:exists?).
          with(fallbacks.keys[1], I18n.default_locale).
          and_return(true)

        expect(I18n).
          to receive(:translate).
          with('numbers.two', :ni => 2).
          and_return('translated')

        expect(instance.translate_with_fallbacks fallbacks).
          to be == 'translated'
      end # it
    end # context

    context 'when a translation is defined for the third item' do
      it 'should delegate to I18n' do
        expect(I18n).to receive(:exists?).
          with(fallbacks.keys[0], I18n.default_locale).
          and_return(false)

        expect(I18n).to receive(:exists?).
          with(fallbacks.keys[1], I18n.default_locale).
          and_return(false)

        expect(I18n).to receive(:exists?).
          with(fallbacks.keys[2], I18n.default_locale).
          and_return(true)

        expect(I18n).
          to receive(:translate).
          with('numbers.three', :san => 3).
          and_return('translated')

        expect(instance.translate_with_fallbacks fallbacks).
          to be == 'translated'
      end # it
    end # context

    context 'when a translation is not defined' do
      let(:expected) do
        "translation missing: #{I18n.default_locale}.numbers.three"
      end # let

      it 'should delegate to I18n' do
        expect(I18n).to receive(:exists?).
          with(fallbacks.keys[0], I18n.default_locale).
          and_return(false)

        expect(I18n).to receive(:exists?).
          with(fallbacks.keys[1], I18n.default_locale).
          and_return(false)

        expect(I18n).to receive(:exists?).
          with(fallbacks.keys[2], I18n.default_locale).
          and_return(false)

        expect(I18n).
          to receive(:translate).
          with('numbers.three', :san => 3).
          and_return(expected)

        expect(instance.translate_with_fallbacks fallbacks).
          to be == expected
      end # it
    end # context

    wrap_context 'when a default locale is set' do
      context 'when a translation is defined for the first item' do
        it 'should delegate to I18n' do
          expect(I18n).to receive(:exists?).
            with(fallbacks.keys[0], default_locale).
            and_return(true)

          expect(I18n).
            to receive(:translate).
            with('numbers.one', :ichi => 1).
            and_return('translated')

          expect(instance.translate_with_fallbacks fallbacks).
            to be == 'translated'
        end # it

        describe 'when a locale is set' do
          let(:locale) { 'fr-FR' }

          it 'should delegate to I18n' do
            expect(I18n).to receive(:exists?).
              with(fallbacks.keys[0], locale).
              and_return(true)

            expect(I18n).
              to receive(:translate).
              with('numbers.one', :ichi => 1).
              and_return('translated')

            expect(instance.translate_with_fallbacks fallbacks, locale).
              to be == 'translated'
          end # it
        end # describe
      end # context

      context 'when a translation is defined for the second item' do
        it 'should delegate to I18n' do
          expect(I18n).to receive(:exists?).
            with(fallbacks.keys[0], default_locale).
            and_return(false)

          expect(I18n).to receive(:exists?).
            with(fallbacks.keys[1], default_locale).
            and_return(true)

          expect(I18n).
            to receive(:translate).
            with('numbers.two', :ni => 2).
            and_return('translated')

          expect(instance.translate_with_fallbacks fallbacks).
            to be == 'translated'
        end # it
      end # context

      context 'when a translation is defined for the third item' do
        it 'should delegate to I18n' do
          expect(I18n).to receive(:exists?).
            with(fallbacks.keys[0], default_locale).
            and_return(false)

          expect(I18n).to receive(:exists?).
            with(fallbacks.keys[1], default_locale).
            and_return(false)

          expect(I18n).to receive(:exists?).
            with(fallbacks.keys[2], default_locale).
            and_return(true)

          expect(I18n).
            to receive(:translate).
            with('numbers.three', :san => 3).
            and_return('translated')

          expect(instance.translate_with_fallbacks fallbacks).
            to be == 'translated'
        end # it
      end # context

      context 'when a translation is not defined' do
        let(:expected) do
          "translation missing: #{default_locale}.numbers.three"
        end # let

        it 'should delegate to I18n' do
          expect(I18n).to receive(:exists?).
            with(fallbacks.keys[0], default_locale).
            and_return(false)

          expect(I18n).to receive(:exists?).
            with(fallbacks.keys[1], default_locale).
            and_return(false)

          expect(I18n).to receive(:exists?).
            with(fallbacks.keys[2], default_locale).
            and_return(false)

          expect(I18n).
            to receive(:translate).
            with('numbers.three', :san => 3).
            and_return(expected)

          expect(instance.translate_with_fallbacks fallbacks).
            to be == expected
        end # it
      end # context
    end # wrap_context
  end # describe
end # describe
