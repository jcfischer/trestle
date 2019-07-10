module Trestle
  module Adapters
    module ActiveResourceAdapter

      # Implements a rudimentary ActiveResource Adapter for Trestle
      #
      #   class Plan < ActiveResource::Base
      #     self.site = 'http://example.org/api/v1.0'
      #     set_collection_name 'plan'           # the API uses a non pluralized path
      #     self.include_format_in_path = false  # don't add .json
      #
      #     # define the schema of the data, so that Trestle can build a form for it
      #     schema do
      #       attribute 'id', :integer
      #       attribute 'name', :string
      #       attribute 'discount', :float
      #       attribute 'offeredStartDate', :string
      #       attribute 'offeredEndDate', :string
      #     end
      #
      #   end
      def collection(params={})
        model.all
      end

      def find_instance(params)
        model.find(params[:id])
      end

      def build_instance(attrs={}, params={})
        model.new(type_cast(attrs))
      end

      def update_instance(instance, attrs, params={})
        instance.load(type_cast(attrs))
      end

      def save_instance(instance, params={})
        instance.save
      end

      def delete_instance(instance, params={})
        instance.destroy
      end

      def merge_scopes(scope, other)
        scope.merge(other)
      end

      def count(collection)
        collection.count
      end

      def sort(collection, field, order)
        collection.reorder(field => order)
      end

      def default_table_attributes
        default_attributes.reject do |attribute|
          inheritance_column?(attribute)
        end
      end

      def default_form_attributes
        default_attributes.reject do |attribute|
          primary_key?(attribute) || inheritance_column?(attribute)
        end
      end

      protected

      def default_attributes
        # be sure to define a schema in the ActiveRecord definition of the
        # API class so that the form builder will work
        #
        model.schema.map do |field_name, field_type|
          Attribute.new(field_name, field_type.to_sym)
        end
      end

      # TODO: Associations aren't done yet, keeping the old code for reference (jcf, 2019-07-09)
      # def default_attributes
      #   model.db_schema.map do |column_name, column_attrs|
      #     if column_name.to_s.end_with?("_id") && (name = column_name.to_s.sub(/_id$/, '')) && (reflection = model.association_reflection(name.to_sym))
      #       Attribute::Association.new(column_name, class: -> { reflection.associated_class }, name: name)
      #     else
      #       Attribute.new(column_name, column_attrs[:type])
      #     end
      #   end
      # end

      def primary_key?(attribute)
        attribute.name.to_s == model.primary_key
      end

      # STI inheritance is not supported
      def inheritance_column?(attribute)
        false
      end

      # type casts any strings to the correct representation for JSONApis
      # some APIs will barf on receiving strings instead of numbers
      def type_cast(attrs)
        h = {}
        attrs.each do |attr, value|
          case model.schema[attr.to_sym].to_sym
          when :integer
            h[attr] = value.to_i rescue 0
          when :float
            h[attr] = value.to_f rescue 0.0
          else
            h[attr] = value
          end
        end
        h
      end
    end
  end
end
