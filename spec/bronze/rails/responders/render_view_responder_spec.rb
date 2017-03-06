# spec/bronze/rails/responders/render_view_responder_spec.rb

require 'bronze/rails/responders/render_view_responder'

RSpec.describe Bronze::Rails::Responders::RenderViewResponder do
  let(:render_context) do
    double('render_context', :render => nil, :redirect_to => nil)
  end # let
  let(:instance) { described_class.new render_context }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#call' do
    let(:options) { {} }

    it { expect(instance).to respond_to(:call).with(1).argument }

    describe 'with a redirect path' do
      let(:redirect_path) { '/resources' }
      let(:options)       { super().merge :redirect_path => redirect_path }

      it 'should redirect to the requested path' do
        expect(render_context).not_to receive(:render)

        expect(render_context).to receive(:redirect_to).with(redirect_path)

        instance.call(options)
      end # it
    end # describe

    describe 'with a template path' do
      shared_examples 'should render the template' do
        it 'should render the template' do
          expect(render_context).not_to receive(:redirect_to)

          expect(render_context).to receive(:render) do |hsh|
            expect(hsh[:template]).to be == template
            expect(hsh[:status]).to be == expected_status
            expect(hsh[:locals]).to be == expected_locals
          end # expect

          instance.call(options)
        end # it
      end # shared_examples

      let(:template)        { '/resources/index' }
      let(:options)         { super().merge :template => template }
      let(:expected_locals) { {} }
      let(:expected_status) { :ok }

      include_examples 'should render the template'

      describe 'with an http_status option' do
        let(:options)         { super().merge :http_status => :created }
        let(:expected_status) { :created }

        include_examples 'should render the template'
      end # describe

      describe 'with a resources option' do
        let(:resources) do
          {
            :book     => double('book'),
            :chapters => Array.new(3) { double('chapter') }
          } # end resources
        end # let
        let(:options)         { super().merge :resources => resources }
        let(:expected_locals) { resources }

        include_examples 'should render the template'
      end # describe

      describe 'with an errors option' do
        let(:errors)          { Array.new(3) { double('error') } }
        let(:options)         { super().merge :errors => errors }
        let(:expected_locals) { { :errors => errors } }

        include_examples 'should render the template'
      end # describe

      describe 'with a locals option' do
        let(:locals) do
          {
            :key => double('value'),
            :ary => Array.new(3) { double('item') }
          } # end locals
        end # let
        let(:options)         { super().merge :locals => locals }
        let(:expected_locals) { locals }

        include_examples 'should render the template'
      end # describe
    end # describe
  end # describe

  describe '#render_context' do
    include_examples 'should have reader',
      :render_context,
      ->() { be == render_context }
  end # describe
end # describe
