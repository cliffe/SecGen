#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_string_generator.rb'
class ProductTableHeadingsGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'product table headings'
  end

  def generate
    table_name = ['Product','product', 'Products', 'products', 'merchandise', 'stock']
    selected_table_name = table_name.sample

    product_name_column = ['product_title','name', 'product', 'item', 'stock_name']
    selected_product_name_heading = product_name_column.sample

    price_column = ['price', 'charge', 'rrp', 'cost']
    selected_price_heading = price_column.sample

    image_column = ['image', 'img', 'thumbnail', 'product_image', 'product_img', 'pic', 'picture']
    selected_image_heading = image_column.sample

    output = selected_table_name + "," + selected_product_name_heading + "," + selected_price_heading + "," + selected_image_heading

    self.outputs << output
  end
end

ProductTableHeadingsGenerator.new.run
