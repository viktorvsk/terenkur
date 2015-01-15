module Permalinkable

  extend ActiveSupport::Concern

  def self.included(base)

    base.class_eval do

      before_validation :compose_permalink

      private
      def compose_permalink
        self.permalink = Russian.translit(name).parameterize unless self.permalink.present?
      end

    end
  end

  module ClassMethods
  end

end