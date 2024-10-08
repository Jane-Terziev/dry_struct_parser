# frozen_string_literal: true

module DryStructParser
  class StructSchemaParser
    PREDICATE_TYPES = {
      String: "string",
      Integer: "integer",
      TrueClass: "boolean",
      FalseClass: "boolean",
      Float: "float",
      BigDecimal: "decimal",
      Date: "date",
      DateTime: "datetime",
      Time: "time"
    }.freeze

    attr_reader :keys

    def initialize
      @keys = {}
    end

    def to_h
      { keys: keys }
    end

    def call(struct, &block)
      @keys = {}
      visit(struct.schema.to_ast)
      instance_eval(&block) if block_given?
      self
    end

    def visit(node, opts = {})
      meth, rest = node
      public_send(:"visit_#{meth}", rest, opts)
    end

    def visit_constructor(node, opts = {})
      visit(node[0], opts)
    end

    def visit_schema(node, opts = {})
      target = (key = opts[:key]) ? self.class.new : self
      required = opts.fetch(:required, true)
      nullable = opts.fetch(:nullable, false)
      node[0].each { |child| target.visit(child) }
      return unless key

      target_info = target.to_h if opts[:member]
      type = opts[:array] ? "array" : "hash"
      definition = {
        type: type,
        required: required,
        nullable: nullable,
        **target_info
      }
      if opts[:oneOf]
        keys[key] ? keys[key] << definition : keys[key] = [definition]
      else
        keys[key] = definition
      end

      keys[key]
    end

    def visit_key(node, opts = {})
      name, required, rest = node
      opts[:key] = name
      opts[:required] = required
      visit(rest, opts)
    end

    def visit_constrained(node, opts = {})
      node.each { |it| visit(it, opts) }
    end

    def visit_nominal(_node, _opts); end

    def visit_predicate(node, opts = {})
      name, rest = node
      type = rest[0][1]
      if name.equal?(:type?)
        type = type.to_s.to_sym
        return unless PREDICATE_TYPES[type]

        type_definition = {
          type: PREDICATE_TYPES[type],
          required: opts.fetch(:required),
          nullable: opts.fetch(:nullable, false)
        }
        type_definition[:array] = opts[:array] if opts[:array]
        keys[opts[:key]] = type_definition
      elsif name.equal?(:included_in?)
        type += [nil] if opts.fetch(:nullable, false)
        keys[opts[:key]][:enum] = type
      end
    end

    def visit_and(node, opts = {})
      left, right = node
      visit(left, opts)
      visit(right, opts)
    end

    def visit_enum(node, opts = {})
      visit(node[0], opts)
    end

    def visit_sum(node, opts = {})
      if node[0][0].equal?(:constrained)
        opts[:nullable] = true if node[0][1][0][1][0].equal?(NilClass)
        visit(node[1], opts) # ignore NilClass constrained
      elsif node[0][0].equal?(:struct) || node[0][0].equal?(:sum)
        opts[:oneOf] = true
        node.each { |child| visit(child, opts) unless child.is_a?(Hash) }
      end
    end

    def visit_any(_, opts)
      keys[opts[:key]] = { type: :any, required: opts.fetch(:required), nullable: opts.fetch(:nullable, false) }
    end

    def visit_struct(node, opts = {})
      opts[:member] = true
      visit(node[1], opts)
    end

    def visit_array(node, opts = {})
      opts[:array] = true
      visit(node[0], opts)
    end
  end
end
