# spec/integration/controllers/magazines_controller_spec.rb

require 'rails_helper'

require 'integration/controllers/controller_examples'

RSpec.describe MagazinesController, :type => :controller do
  include Spec::Examples::Integration::ControllerExamples

  shared_context 'when the collection has many magazines' do
    let(:magazines_attributes) do
      [
        {
          :title  => 'Dungeon Magazine',
          :volume => 1
        }, # end magazine
        {
          :title  => 'Dungeon Magazine',
          :volume => 2
        }, # end magazine
        {
          :title  => 'Dungeon Magazine',
          :volume => 3
        }, # end magazine
        {
          :title  => 'Dragon Magazine',
          :volume => 1
        }, # end magazine
        {
          :title  => 'Dragon Magazine',
          :volume => 2
        }, # end magazine
        {
          :title  => 'Dragon Magazine',
          :volume => 3
        } # end magazine
      ] # end attributes
    end # let
    let!(:magazines) do
      magazines_attributes.map do |hsh|
        magazine = Spec::Magazine.new hsh

        magazines_collection.insert magazine

        magazine
      end # each
    end # let
  end # shared_context

  shared_examples 'should require a magazine id' do
    describe 'when the magazine id is invalid' do
      let(:magazine_id) { Spec::Magazine.new.id }

      include_examples 'should redirect to',
        ->() { magazines_path },
        :as => 'magazines_path'

      it 'should set the flash' do
        perform_action

        expect(controller.flash[:warning]).to include 'Unable to find magazine.'
      end # it
    end # describe
  end # shared_examples

  let(:magazines_collection) do
    transform =
      Bronze::Entities::Transforms::EntityTransform.new(Spec::Magazine)

    controller.send(:repository).collection(Spec::Magazine, transform)
  end # let

  let(:params)  { {} }
  let(:headers) { {} }

  describe '#create' do
    let(:attributes) { {} }
    let(:params)     { super().merge :magazine => attributes }

    def perform_action
      post :create, :headers => headers, :params => params
    end # method perform_action

    describe 'with invalid attributes' do
      let(:attributes) do
        { :title => 'Annals of the Illuminati' }
      end # let
      let(:expected_attributes) do
        hsh = {}

        Spec::Magazine.attributes.keys.each do |attr_name|
          next if attr_name == :id

          hsh[attr_name] = attributes[attr_name]
        end # each

        hsh
      end # let
      let(:expected_errors) { { 'magazine[volume]' => ['must be present'] } }

      include_examples 'should render template',
        'magazines/new',
        { :status => :unprocessable_entity },
        lambda { |options|
          magazine = options[:locals][:magazine]
          magazine_attributes = magazine.attributes.tap { |hsh| hsh.delete :id }

          expect(magazine).to be_a Spec::Magazine
          expect(magazine_attributes).to be == expected_attributes

          errors = options[:locals][:errors]
          expect(errors).to be == expected_errors
        } # end include_examples

      it 'should set the flash' do
        perform_action

        expect(controller.flash.now[:warning]).
          to include 'Unable to create magazine.'
      end # it

      it 'should not create a magazine' do
        expect { perform_action }.not_to change(magazines_collection, :count)
      end # it
    end # describe

    describe 'with valid attributes' do
      let(:attributes) do
        {
          :title  => 'Dungeon Magazine',
          :volume => 4
        } # attributes
      end # let
      let(:created_magazine) { magazines_collection.matching(attributes).one }

      include_examples 'should redirect to',
        ->() { magazine_path(created_magazine) },
        :as => 'magazine_path'

      it 'should create the magazine' do
        expect { perform_action }.to change(magazines_collection, :count).by(1)

        attributes.each do |attr_name, value|
          expect(created_magazine.send attr_name).to be == value
        end # each
      end # it

      it 'should set the flash' do
        perform_action

        expect(controller.flash[:success]).
          to include 'Successfully created magazine.'
      end # it
    end # describe

    wrap_context 'when the collection has many magazines' do
      describe 'with attributes for a non-unique magazine' do
        let(:attributes) do
          {
            :title  => 'Dungeon Magazine',
            :volume => 2
          } # attributes
        end # let
        let(:expected_attributes) do
          hsh = {}

          Spec::Magazine.attributes.keys.each do |attr_name|
            next if attr_name == :id

            hsh[attr_name] = attributes[attr_name]
          end # each

          hsh
        end # let
        let(:expected_errors) { { 'magazine' => ['is not unique'] } }

        include_examples 'should render template',
          'magazines/new',
          { :status => :unprocessable_entity },
          lambda { |options|
            magazine = options[:locals][:magazine]
            magazine_attributes =
              magazine.attributes.tap { |hsh| hsh.delete :id }

            expect(magazine).to be_a Spec::Magazine
            expect(magazine_attributes).to be == expected_attributes

            errors = options[:locals][:errors]
            expect(errors).to be == expected_errors
          } # end include_examples

        it 'should set the flash' do
          perform_action

          expect(controller.flash.now[:warning]).
            to include 'Unable to create magazine.'
        end # it

        it 'should not create a magazine' do
          expect { perform_action }.not_to change(magazines_collection, :count)
        end # it
      end # describe

      describe 'with attributes for a unique magazine' do
        let(:attributes) do
          {
            :title  => 'Dungeon Magazine',
            :volume => 4
          } # attributes
        end # let
        let(:created_magazine) { magazines_collection.matching(attributes).one }

        include_examples 'should redirect to',
          ->() { magazine_path(created_magazine) },
          :as => 'magazine_path'

        it 'should create the magazine' do
          expect { perform_action }.
            to change(magazines_collection, :count).
            by(1)

          attributes.each do |attr_name, value|
            expect(created_magazine.send attr_name).to be == value
          end # each
        end # it

        it 'should set the flash' do
          perform_action

          expect(controller.flash[:success]).
            to include 'Successfully created magazine.'
        end # it
      end # describe
    end # wrap_context
  end # describe

  describe '#update' do
    include_context 'when the collection has many magazines'

    let(:magazine)    { magazines_collection.to_a.first }
    let(:magazine_id) { magazine.id }
    let(:params) do
      super().merge :id => magazine_id, :magazine => update_attributes
    end # let
    let(:update_attributes) do
      {}
    end # let

    def perform_action
      patch :update, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should require a magazine id'

    describe 'with invalid attributes' do
      let(:update_attributes) do
        { :title => '' }
      end # let
      let(:expected_attributes) do
        magazine.attributes.
          merge(update_attributes).
          tap { |hsh| hsh.delete :id }
      end # let
      let(:expected_errors) { { 'magazine[title]' => ['must be present'] } }

      include_examples 'should render template',
        'magazines/edit',
        { :status => :unprocessable_entity },
        lambda { |options|
          changed_magazine = options[:locals][:magazine]
          magazine_attributes =
            changed_magazine.attributes.tap { |hsh| hsh.delete :id }

          expect(changed_magazine).to be_a Spec::Magazine
          expect(magazine_attributes).to be == expected_attributes

          errors = options[:locals][:errors]
          expect(errors).to be == expected_errors
        } # end include_examples

      it 'should not update the magazine' do
        expect { perform_action }.
          not_to change { magazines_collection.find(magazine.id).attributes }
      end # it

      it 'should set the flash' do
        perform_action

        expect(controller.flash.now[:warning]).
          to include 'Unable to update magazine.'
      end # it
    end # describe

    describe 'with non-unique attributes with a matching id' do
      let(:update_attributes) do
        { :publisher => 'Paizo' }
      end # let
      let(:expected_attributes) do
        magazine.attributes.merge(update_attributes)
      end # let

      include_examples 'should redirect to',
        ->() { magazine_path(magazine) },
        :as => 'magazine_path'

      it 'should update the magazine' do
        expect { perform_action }.
          to change { magazines_collection.find(magazine.id).attributes }.
          to be == expected_attributes
      end # it

      it 'should set the flash' do
        perform_action

        expect(controller.flash[:success]).
          to include 'Successfully updated magazine.'
      end # it
    end # describe

    describe 'with non-unique attributes with a non-matching id' do
      let(:update_attributes) do
        { :volume => 2 }
      end # let
      let(:expected_attributes) do
        magazine.attributes.
          merge(update_attributes).
          tap { |hsh| hsh.delete :id }
      end # let
      let(:expected_errors) { { 'magazine' => ['is not unique'] } }

      include_examples 'should render template',
        'magazines/edit',
        { :status => :unprocessable_entity },
        lambda { |options|
          changed_magazine = options[:locals][:magazine]
          magazine_attributes =
            changed_magazine.attributes.tap { |hsh| hsh.delete :id }

          expect(changed_magazine).to be_a Spec::Magazine
          expect(magazine_attributes).to be == expected_attributes

          errors = options[:locals][:errors]
          expect(errors).to be == expected_errors
        } # end include_examples

      it 'should not update the magazine' do
        expect { perform_action }.
          not_to change { magazines_collection.find(magazine.id).attributes }
      end # it

      it 'should set the flash' do
        perform_action

        expect(controller.flash.now[:warning]).
          to include 'Unable to update magazine.'
      end # it
    end # describe

    describe 'with unique attributes' do
      let(:update_attributes) do
        {
          :title  => 'Dungeon Magazine',
          :volume => 4
        } # attributes
      end # let
      let(:expected_attributes) do
        magazine.attributes.merge(update_attributes)
      end # let

      include_examples 'should redirect to',
        ->() { magazine_path(magazine) },
        :as => 'magazine_path'

      it 'should update the magazine' do
        expect { perform_action }.
          to change { magazines_collection.find(magazine.id).attributes }.
          to be == expected_attributes
      end # it

      it 'should set the flash' do
        perform_action

        expect(controller.flash[:success]).
          to include 'Successfully updated magazine.'
      end # it
    end # describe
  end # describe
end # describe
