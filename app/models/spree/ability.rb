# Implementation class for Cancan gem.  Instead of overriding this class, consider adding new permissions
# using the special +register_ability+ method which allows extensions to add their own abilities.
#
# See http://github.com/ryanb/cancan for more details on cancan.
require 'cancan'
module Spree
  class Ability
    include CanCan::Ability

    class_attribute :abilities
    self.abilities = Set.new

    # Allows us to go beyond the standard cancan initialize method which makes it difficult for engines to
    # modify the default +Ability+ of an application.  The +ability+ argument must be a class that includes
    # the +CanCan::Ability+ module.  The registered ability should behave properly as a stand-alone class
    # and therefore should be easy to test in isolation.
    def self.register_ability(ability)
      self.abilities.add(ability)
    end

    def self.remove_ability(ability)
      self.abilities.delete(ability)
    end

    def initialize(user)
      self.clear_aliased_actions

      # override cancan default aliasing (we don't want to differentiate between read and index)
      alias_action :delete, to: :destroy
      alias_action :edit, to: :update
      alias_action :new, to: :create
      alias_action :new_action, to: :create
      alias_action :show, to: :read
      alias_action :index, :read, to: :display


      user ||= Spree.user_class.new

      if user.respond_to?(:has_spree_role?) && user.has_spree_role?('admin')
        can :manage, :all
      else
        can :display, Country
        can :display, OptionType
        can :display, OptionValue
        can :create, Order
        can [:read, :update], Order do |order, token|
          order.user == user || order.guest_token && token == order.guest_token
        end
        can :display, CreditCard, user_id: user.id
        can :display, Product
        can :display, ProductProperty
        can :display, Property
        can :create, Spree.user_class
        can [:read, :update, :destroy], Spree.user_class, id: user.id
        can :display, State
        can :display, Taxon
        can :display, Taxonomy
        can :display, Variant
        can :display, Zone
      end




    


      if user.respond_to?(:has_spree_role?) && user.has_spree_role?('blogger')
        p "---------------------------------------------------------------"
        can :manage, Spree::BlogEntry
        cannot :manage, Spree::Promotion
        cannot :manage, Spree::Taxonomy
        cannot :manage, Spree::SalePerformance
        cannot :manage, Spree::Product
        cannot :manage, Spree::Order
        cannot :manage, Spree::Lead
        cannot :manage, Notification

      end

      if (user.respond_to?(:has_spree_role?) && user.has_spree_role?('sales_rep')) 
         can :manage, Spree::Product
        can :manage, Spree::Order
         can :manage, Spree::Lead
        can :manage, Notification
        cannot :manage, Spree::BlogEntry
        cannot :manage, Spree::Promotion
        cannot :manage, Spree::Taxonomy
        cannot :manage, Spree::SalePerformance
        cannot :manage, Spree::User
        cannot :manage, Report
      end
     
      if (user.respond_to?(:has_spree_role?) && user.has_spree_role?('manager'))
        can :manage, Spree::Product
        can :manage, Spree::Order
         can :manage, Spree::Lead
        can :manage, Notification
        can :manage, Spree::BlogEntry
        cannot :manage, Spree::Promotion
        cannot :manage, Spree::Taxonomy
        cannot :manage, Spree::SalePerformance
        cannot :manage, Spree::User
        cannot :manage, Report
      end 




      
      


   

      # Include any abilities registered by extensions, etc.
      Ability.abilities.each do |clazz|
        ability = clazz.send(:new, user)
        @rules = rules + ability.send(:rules)
      end
    end
  end
end
