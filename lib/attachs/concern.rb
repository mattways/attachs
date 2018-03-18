module Attachs
  module Concern
    extend ActiveSupport::Concern

    module ClassMethods

      def inherited(subclass)
        subclass.instance_variable_set :@attachments, @attachments
        super
      end

      def attachments
        @attachments ||= {}
      end

      def attachable?
        attachments.any?
      end

      def has_attachment?(name)
        attachments.has_key? name.to_sym
      end

    end
  end
end
