# frozen_string_literal: true

module Logux
  module Process
    class Action
      attr_reader :chunk

      def initialize(chunk:)
        @chunk = chunk
      end

      def call
        if authorizated?
          process_action!
          ['processed', meta_from_chunk.id]
        else
          ['forbidden', meta_from_chunk.id]
        end
      end

      def action_from_chunk
        @action_from_chunk ||= chunk[:action]
      end

      def meta_from_chunk
        @meta_from_chunk ||= chunk[:meta]
      end

      private

      def process_action!
        Logux::ActionCaller.new(
          action: action_from_chunk,
          meta: meta_from_chunk
        ).call!
      end

      def authorizated?
        Logux::PolicyCaller.new(
          action: action_from_chunk,
          meta: meta_from_chunk
        ).call!
      end
    end
  end
end
