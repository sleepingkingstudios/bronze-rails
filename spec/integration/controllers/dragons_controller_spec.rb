# spec/integration/controllers/dragons_controller_spec.rb

require 'rails_helper'

require 'integration/controllers/controller_examples'

RSpec.describe DragonsController, :type => :controller do
  include Spec::Examples::Integration::ControllerExamples

  shared_context 'when the collection has many dungeons' do
    let(:dungeons_attributes) do
      [
        { :name => 'Haunted House on the Hill' },
        { :name => 'Mountain of the Mad Gnome' },
        { :name => 'Sunken Halls of the Naga Queen' }
      ] # end titles
    end # let
    let!(:dungeons) do
      dungeons_attributes.map do |hsh|
        dungeon = Spec::Dungeon.new hsh

        dungeons_collection.insert dungeon

        dungeon
      end # each
    end # let
  end # shared_context

  shared_context 'when the collection has many dragons' do
    include_context 'when the collection has many dungeons'

    let(:dragons_attributes) do
      [
        {
          :name     => 'Grendel the Green',
          :wingspan => 64
        }, # end dragon
        {
          :name     => 'Ambrose the Amber',
          :wingspan => 48
        }, # end dragon
        {
          :name     => 'Charlie the Chartreuse',
          :wingspan => 56
        }, # end dragon
        {
          :name     => 'Nutelloth the Hazel',
          :wingspan => 56
        }, # end dragon
        {
          :name     => 'Citrath the Orange',
          :wingspan => 49
        }, # end dragon
        {
          :name     => 'Barragoth the Banana-Hued',
          :wingspan => 63
        }, # end dragon
        {
          :name     => 'Invidius the Infrared',
          :wingspan => 72
        }, # end dragon
        {
          :name     => 'Ulysses the Ultraviolet',
          :wingspan => 63
        }, # end dragon
        {
          :name     => 'Octavius the Octarine',
          :wingspan => 81
        }, # end dragon
      ] # end titles
    end # let
    let!(:dragons) do
      dungeons.map.with_index do |lair, index|
        offset = 3 * index

        dragons_attributes[offset...(offset + 3)].map do |hsh|
          dragon = Spec::Dragon.new hsh.merge(:lair => lair)

          dragons_collection.insert dragon

          dragon
        end # each
      end. # map
        flatten
    end # let
  end # shared_context

  shared_examples 'should require a dungeon id' do
    describe 'when the lair id is invalid' do
      let(:dungeon_id) { Spec::Dungeon.new.id }

      include_examples 'should redirect to',
        ->() { dungeons_path },
        :as => 'dungeons_path'
    end # describe
  end # shared_examples

  shared_examples 'should require a dragon id' do
    describe 'when the dragon id is invalid' do
      let(:dragon_id) { Spec::Dragon.new.id }

      include_examples 'should redirect to',
        ->() { dungeon_dragons_path(dungeon) },
        :as => 'dungeon_dragons_path'
    end # describe
  end # shared_examples

  let(:dragons_collection) do
    transform =
      Bronze::Entities::Transforms::EntityTransform.new(Spec::Dragon)

    controller.send(:repository).collection(Spec::Dragon, transform)
  end # let
  let(:dungeons_collection) do
    transform =
      Bronze::Entities::Transforms::EntityTransform.new(Spec::Dungeon)

    controller.send(:repository).collection(Spec::Dungeon, transform)
  end # let

  let(:params)  { {} }
  let(:headers) { {} }

  describe '#create' do
    include_context 'when the collection has many dragons'

    let(:dungeon)    { dungeons.first }
    let(:dungeon_id) { dungeon.id }
    let(:attributes) { {} }
    let(:params) do
      super().merge :dungeon_id => dungeon_id, :dragon => attributes
    end # let

    def perform_action
      post :create, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should require a dungeon id'

    describe 'with invalid attributes' do
      let(:attributes) { { :wingspan => 48 } }
      let(:expected_attributes) do
        hsh = {}

        Spec::Dragon.attributes.keys.each do |attr_name|
          next if attr_name == :id

          hsh[attr_name] = attributes[attr_name]
        end # each

        hsh[:lair_id] = dungeon.id

        hsh
      end # let
      let(:expected_errors) { { 'dragon[name]' => ['must be present'] } }

      include_examples 'should render template',
        'dragons/new',
        { :status => :unprocessable_entity },
        lambda { |options|
          expect(options[:locals][:lair]).to be == dungeon

          dragon = options[:locals][:dragon]
          dragon_attributes = dragon.attributes.tap { |hsh| hsh.delete :id }

          expect(dragon).to be_a Spec::Dragon
          expect(dragon.lair).to be == dungeon
          expect(dragon_attributes).to be == expected_attributes

          errors = options[:locals][:errors]
          expect(errors).to be == expected_errors
        } # end include_examples

      it 'should not create a dragon' do
        expect { perform_action }.not_to change(dragons_collection, :count)
      end # it
    end # describe

    describe 'with valid attributes' do
      let(:attributes) do
        {
          :name     => 'Polychromius the Prideful',
          :wingspan => 100
        } # attributes
      end # let
      let(:created_dragon) { dragons_collection.matching(attributes).one }

      include_examples 'should redirect to',
        ->() { dungeon_dragon_path(dungeon, created_dragon) },
        :as => 'dungeon_dragon_path'

      it 'should create the dragon' do
        expect { perform_action }.to change(dragons_collection, :count).by(1)

        expect(created_dragon.lair_id).to be == dungeon.id

        attributes.each do |attr_name, value|
          expect(created_dragon.send attr_name).to be == value
        end # each
      end # it
    end # describe
  end # describe

  describe '#destroy' do
    include_context 'when the collection has many dragons'

    let(:dungeon)    { dungeons_collection.to_a.first }
    let(:dungeon_id) { dungeon.id }
    let(:dragon) do
      dragons_collection.matching(:lair_id => dungeon.id).to_a.first
    end # let
    let(:dragon_id) { dragon.id }
    let(:params) do
      super().merge :dungeon_id => dungeon_id, :id => dragon_id
    end # let

    def perform_action
      delete :destroy, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should require a dungeon id'

    include_examples 'should require a dragon id'

    it 'should destroy the dragon' do
      expect { perform_action }.to change(dragons_collection, :count).by(-1)

      expect(dragons_collection.find dragon.id).to be nil
    end # it
  end # describe

  describe '#edit' do
    include_context 'when the collection has many dragons'

    let(:dungeon)    { dungeons_collection.to_a.first }
    let(:dungeon_id) { dungeon.id }
    let(:dragon) do
      dragons_collection.matching(:lair_id => dungeon.id).to_a.first
    end # let
    let(:dragon_id) { dragon.id }
    let(:params) do
      super().merge :dungeon_id => dungeon_id, :id => dragon_id
    end # let

    def perform_action
      get :edit, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should require a dungeon id'

    include_examples 'should require a dragon id'

    include_examples 'should render template',
      'dragons/edit',
      lambda { |options|
        expect(options[:locals][:lair]).to be == dungeon

        found_dragon = options[:locals][:dragon]

        expect(found_dragon).to be == dragon
        expect(found_dragon.lair).to be == dungeon
      } # end include_examples
  end # describe

  describe '#index' do
    include_context 'when the collection has many dungeons'

    let(:dungeon)    { dungeons.first }
    let(:dungeon_id) { dungeon.id }
    let(:params)     { super().merge :dungeon_id => dungeon_id }

    def perform_action
      get :index, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should require a dungeon id'

    include_examples 'should render template',
      'dragons/index',
      lambda { |options|
        expect(options[:locals][:lair]).to be == dungeon

        matching_dragons = options[:locals][:dragons]

        expect(matching_dragons).to be_a Array
        expect(matching_dragons.empty?).to be true
      } # end include_examples

    wrap_context 'when the collection has many dragons' do
      let(:expected) do
        dragons.select { |dragon| dragon.lair_id == dungeon_id }
      end # let

      include_examples 'should render template',
        'dragons/index',
        lambda { |options|
          expect(options[:locals][:lair]).to be == dungeon

          matching_dragons = options[:locals][:dragons]

          expect(matching_dragons).to be_a Array
          expect(matching_dragons).to contain_exactly(*expected)

          matching_dragons.each do |matching_dragon|
            expect(matching_dragon.lair).to be == dungeon
          end # each
        } # end include_examples
    end # wrap_context
  end # describe

  describe '#new' do
    include_context 'when the collection has many dungeons'

    let(:dungeon)    { dungeons.first }
    let(:dungeon_id) { dungeon.id }
    let(:attributes) { {} }
    let(:params) do
      super().merge :dungeon_id => dungeon_id, :chapter => attributes
    end # let
    let(:expected_attributes) do
      hsh = {}

      Spec::Dragon.attributes.keys.each do |attr_name|
        next if attr_name == :id

        hsh[attr_name] = nil
      end # each

      hsh[:lair_id] = dungeon.id

      hsh
    end # let

    def perform_action
      get :new, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should require a dungeon id'

    include_examples 'should render template',
      'dragons/new',
      lambda { |options|
        expect(options[:locals][:lair]).to be == dungeon

        dragon = options[:locals][:dragon]
        dragon_attributes = dragon.attributes.tap { |hsh| hsh.delete :id }

        expect(dragon).to be_a Spec::Dragon
        expect(dragon.lair).to be == dungeon
        expect(dragon_attributes).to be == expected_attributes
      } # end include_examples
  end # describe

  describe '#show' do
    include_context 'when the collection has many dragons'

    let(:dungeon)    { dungeons_collection.to_a.first }
    let(:dungeon_id) { dungeon.id }
    let(:dragon) do
      dragons_collection.matching(:lair_id => dungeon.id).to_a.first
    end # let
    let(:dragon_id) { dragon.id }
    let(:params) do
      super().merge :dungeon_id => dungeon_id, :id => dragon_id
    end # let

    def perform_action
      get :show, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should require a dungeon id'

    include_examples 'should require a dragon id'

    include_examples 'should render template',
      'dragons/show',
      lambda { |options|
        expect(options[:locals][:lair]).to be == dungeon

        found_dragon = options[:locals][:dragon]

        expect(found_dragon).to be == dragon
        expect(found_dragon.lair).to be == dungeon
      } # end include_examples
  end # describe

  describe '#update' do
    include_context 'when the collection has many dragons'

    let(:dungeon)    { dungeons_collection.to_a.first }
    let(:dungeon_id) { dungeon.id }
    let(:dragon) do
      dragons_collection.matching(:lair_id => dungeon.id).to_a.first
    end # let
    let(:dragon_id) { dragon.id }
    let(:params) do
      super().merge(
        :dungeon_id => dungeon_id,
        :id         => dragon_id,
        :dragon     => update_attributes
      ) # end merge
    end # let
    let(:update_attributes) do
      {}
    end # let

    def perform_action
      patch :update, :headers => headers, :params => params
    end # method perform_action

    include_examples 'should require a dungeon id'

    include_examples 'should require a dragon id'

    describe 'with invalid attributes' do
      let(:update_attributes) do
        { :name => '' }
      end # let
      let(:expected_attributes) do
        dragon.attributes.merge(update_attributes).tap { |hsh| hsh.delete :id }
      end # let
      let(:expected_errors) { { 'dragon[name]' => ['must be present'] } }

      include_examples 'should render template',
        'dragons/edit',
        { :status => :unprocessable_entity },
        lambda { |options|
          expect(options[:locals][:lair]).to be == dungeon

          changed_dragon = options[:locals][:dragon]
          dragon_attributes =
            changed_dragon.attributes.tap { |hsh| hsh.delete :id }

          expect(changed_dragon).to be_a Spec::Dragon
          expect(changed_dragon.lair).to be == dungeon
          expect(dragon_attributes).to be == expected_attributes

          errors = options[:locals][:errors]
          expect(errors).to be == expected_errors
        } # end include_examples

      it 'should not update the dragon' do
        expect { perform_action }.
          not_to change { dragons_collection.find(dragon.id).attributes }
      end # it
    end # describe

    describe 'with valid attributes' do
      let(:update_attributes) do
        {
          :name     => 'Polychromius the Prideful',
          :wingspan => 100
        } # attributes
      end # let
      let(:expected_attributes) do
        dragon.attributes.merge(update_attributes)
      end # let

      include_examples 'should redirect to',
        ->() { dungeon_dragon_path(dungeon, dragon) },
        :as => 'dungeon_dragon_path'

      it 'should update the chapter' do
        expect { perform_action }.
          to change { dragons_collection.find(dragon.id).attributes }.
          to be == expected_attributes
      end # it
    end # describe
  end # describe
end # describe
