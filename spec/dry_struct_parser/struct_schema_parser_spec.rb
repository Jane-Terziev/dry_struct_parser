# frozen_string_literal: true

require "spec_helper"

RSpec.describe DryStructParser::StructSchemaParser do
  type_definitions = {
    'Nominal types': %w[
      DryStructParser::Types::Nominal::Bool
      DryStructParser::Types::Nominal::Integer
      DryStructParser::Types::Nominal::Float
      DryStructParser::Types::Nominal::Decimal
      DryStructParser::Types::Nominal::String
      DryStructParser::Types::Nominal::Date
      DryStructParser::Types::Nominal::DateTime
      DryStructParser::Types::Nominal::Time
      DryStructParser::Types::Nominal::Any
    ],
    'Strict types': %w[
      DryStructParser::Types::Strict::Bool
      DryStructParser::Types::Strict::Integer
      DryStructParser::Types::Strict::Float
      DryStructParser::Types::Strict::Decimal
      DryStructParser::Types::Strict::String
      DryStructParser::Types::Strict::Date
      DryStructParser::Types::Strict::DateTime
      DryStructParser::Types::Strict::Time
    ],
    'Coercible types': %w[
      DryStructParser::Types::Coercible::String
      DryStructParser::Types::Coercible::Integer
      DryStructParser::Types::Coercible::Float
      DryStructParser::Types::Coercible::Decimal
    ],
    'Params types': %w[
      DryStructParser::Types::Params::Date
      DryStructParser::Types::Params::DateTime
      DryStructParser::Types::Params::Time
      DryStructParser::Types::Params::Bool
      DryStructParser::Types::Params::Integer
      DryStructParser::Types::Params::Float
      DryStructParser::Types::Params::Decimal
    ],
    'JSON types': %w[
      DryStructParser::Types::JSON::Date
      DryStructParser::Types::JSON::DateTime
      DryStructParser::Types::JSON::Time
      DryStructParser::Types::JSON::Decimal
    ]
  }

  let!(:dto) { Class.new(Dry::Struct) }
  let!(:test_dto) { Class.new(Dry::Struct) }
  let!(:test_dto1) { Class.new(Dry::Struct) }

  subject { described_class.new }

  describe "#.call(dto)" do
    describe "with attribute :field" do
      type_definitions.each do |key, array|
        context key.to_s do
          it "should parse all fields correctly without raising error" do
            array.each_with_index { |type, index| dto.attribute :"field#{index}", Object.const_get(type) }
            expect { subject.call(dto) }.to_not raise_error
          end
        end
      end

      context "String.enum(field)" do
        it "should parse all fields correctly without raising error" do
          dto.attribute :field, DryStructParser::Types::String.enum("test1", "test2")
          expect { subject.call(dto) }.to_not raise_error
        end
      end

      context "String.enum(field => value)" do
        it "should parse all fields correctly without raising error" do
          dto.attribute :field, DryStructParser::Types::String.enum("test1" => 0, "test2" => 1)
          expect { subject.call(dto) }.to_not raise_error
        end
      end

      context "nested TestDTO" do
        it "should parse all fields correctly without raising error" do
          dto.attribute :custom_type, test_dto
          expect { subject.call(dto) }.to_not raise_error
        end
      end

      context "nested TestDTO.optional" do
        it "should parse all fields correctly without raising error" do
          dto.attribute :custom_type, test_dto.optional
          expect { subject.call(dto) }.to_not raise_error
        end
      end

      context "Array.of(TestDTO)" do
        it "should parse all fields correctly without raising error" do
          dto.attribute :custom_type, DryStructParser::Types::Array.of(test_dto)
          expect { subject.call(dto) }.to_not raise_error
        end
      end

      context "Array.of(TestDTO).optional" do
        it "should parse all fields correctly without raising error" do
          dto.attribute :custom_type, DryStructParser::Types::Array.of(test_dto).optional
          expect { subject.call(dto) }.to_not raise_error
        end
      end

      context "Array.of(Integer)" do
        it "should parse all fields correctly without raising error" do
          dto.attribute :custom_type, DryStructParser::Types::Array.of(DryStructParser::Types::Integer)
          expect { subject.call(dto) }.to_not raise_error
        end
      end

      context "Array.of(Integer).optional" do
        it "should parse all fields correctly without raising error" do
          dto.attribute :custom_type, DryStructParser::Types::Array.of(DryStructParser::Types::Integer).optional
          expect { subject.call(dto) }.to_not raise_error
        end
      end

      context "Array.of(DTO | DTO)" do
        it "should parse all fields correctly without raising error" do
          dto.attribute :custom_type, DryStructParser::Types::Array.of(test_dto | test_dto1)
          expect { subject.call(dto) }.to_not raise_error
        end
      end

      context "Array.of(DTO | DTO).optional" do
        it "should parse all fields correctly without raising error" do
          dto.attribute :custom_type, DryStructParser::Types::Array.of(test_dto | test_dto1).optional
          expect { subject.call(dto) }.to_not raise_error
        end
      end
    end

    describe "with attribute :field, type.optional" do
      type_definitions.each do |key, array|
        context key.to_s do
          it "should parse all fields correctly without raising error" do
            array.each_with_index { |type, index| dto.attribute :"field#{index}", Object.const_get(type).optional }
            expect { subject.call(dto) }.to_not raise_error
          end
        end
      end

      context "String.enum(field)" do
        it "should parse all fields correctly without raising error" do
          dto.attribute :field, DryStructParser::Types::String.enum("test1", "test2").optional
          expect { subject.call(dto) }.to_not raise_error
        end
      end

      context "String.enum(field => value)" do
        it "should parse all fields correctly without raising error" do
          dto.attribute :field, DryStructParser::Types::String.enum("test1" => 0, "test2" => 1).optional
          expect { subject.call(dto) }.to_not raise_error
        end
      end
    end

    describe "with attribute? :field" do
      type_definitions.each do |key, array|
        context key.to_s do
          it "should parse all fields correctly without raising error" do
            array.each_with_index { |type, index| dto.attribute? :"field#{index}", Object.const_get(type) }
            expect { subject.call(dto) }.to_not raise_error
          end
        end
      end

      context "String.enum(field)" do
        it "should parse all fields correctly without raising error" do
          dto.attribute? :field, DryStructParser::Types::String.enum("test1", "test2")
          expect { subject.call(dto) }.to_not raise_error
        end
      end

      context "String.enum(field => field)" do
        it "should parse all fields correctly without raising error" do
          dto.attribute? :field, DryStructParser::Types::String.enum("test1" => 0, "test2" => 1)
          expect { subject.call(dto) }.to_not raise_error
        end
      end
    end
    describe "attribute? :field, type.optional" do
      type_definitions.each do |key, array|
        context key.to_s do
          it "should parse all fields correctly without raising error" do
            array.each_with_index { |type, index| dto.attribute? :"field#{index}", Object.const_get(type).optional }
            expect { subject.call(dto) }.to_not raise_error
          end
        end
      end

      context "String.enum(field)" do
        it "should parse all fields correctly without raising error" do
          dto.attribute? :field, DryStructParser::Types::String.enum("test1", "test2").optional
          expect { subject.call(dto) }.to_not raise_error
        end
      end

      context "String.enum(field => value)" do
        it "should parse all fields correctly without raising error" do
          dto.attribute? :field, DryStructParser::Types::String.enum("test1" => 0, "test2" => 1).optional
          expect { subject.call(dto) }.to_not raise_error
        end
      end
    end
  end
end
