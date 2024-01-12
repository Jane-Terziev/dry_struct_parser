# DryStructParser

Generate a readable hash from a dry-struct for easier manipulation

The gem is still work in progress and is not yet fully tested.
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dry_struct_parser'
```

And then execute:

    bundle install

## Usage

#### Parsing a Dry::Struct
Lets say we have the following Dry::Validation::Contract definition:

    class DTO1 < Dry::Struct
        attribute :dto1_field, Types::String
    end
    
    class DTO2 < Dry::Struct
        attribute :dto2_field, Types::String
    end
    
    class DTO < Dry::Struct
        attribute :dynamic_dto, DTO1 | DTO2
    end
    parser = DryStructParser::StructSchemaParser.new
    
    parser.call(DTO)
    => {
         "dynamic_dto": [ # ARRAY
           {
             "type": "hash",
             "required": true,
             "nullable": false,
             "keys": {
               "dto1_field": {
                 "type": "string",
                 "required": true,
                 "nullable": false
               }
             }
           },
           {
             "type": "hash",
             "required": true,
             "nullable": false,
             "keys": {
               "dto2_field": {
                 "type": "string",
                 "required": true,
                 "nullable": false
               }
             }
           }
         ]
       }

The required key depends on whether we define the field as attribute or attribute?

For more complex types, for example DTO1 | DTO2 or Types::Array.of(DTO1 | DTO2),
the parser converts the field value to an array of both schemas.

## Overriding fields
You can also modify the fields by passing a block after the .call() method.

    DryStructParser::StructSchemaParser.new.call(DTO) do |it|
      # types = string/integer/hash/array
      
      # Remove a field
      its.keys = it.keys.except(:field_name) 
      
      # Add new field on root level
      it.keys[:new_field_name] = { type: type, required: true/false, nullable: true/false } 
      
      # Add a new field in nested hash/array
      it.keys[:nested_field][:keys][:new_field_name] = { 
        type: type, required: true/false, nullable: true/false
      }
      
      # Remove a field in nested hash/array
      it.keys = it.keys[:nested_field][:keys].except(:field_name)
      
      # Add an array or hash
      it.keys[:nested_field] = { 
        type: "array/hash", required: true/false, nullable:  true/false, keys: {
          # List all nested fields
          new_field: { type: :type, required: true/false, nullable: true/false }
        }
      }
      
      # Add an Array of primitive types, type field needs to be the element type(string, integer, float), 
      and add an array: true flag
      
      it.keys[:array_field_name] = { 
        type: type, array: true, required: true/false, nullable:  true/false 
      }
      
    end


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Jane-Terziev/dry_struct_parser. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/dry_struct_parser/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the DryStructParser project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/dry_struct_parser/blob/master/CODE_OF_CONDUCT.md).
