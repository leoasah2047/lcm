require 'measure'
require File.dirname(__FILE__)+'/xil/engine'
#require File.dirname(__FILE__)+'/xil/style'
#require File.dirname(__FILE__)+'/xil/base'
#require File.dirname(__FILE__)+'/xil/pdf'

raise Exception.new("ActionView::Template is needed.") unless defined? ActionView::Template and ActionView::Template.respond_to? :register_template_handler

module Xil
  mattr_accessor :options
  @@options={:features=>[], :documents_path=>"#{RAILS_ROOT}/private/documents", :subdir_size=>4096, :document_model_name=>:documents, :template_model_name=>:templates, :company_variable=>:current_company, :crypt=>:rijndael}

  class TemplateHandler < ActionView::TemplateHandler
    include ActionView::TemplateHandlers::Compilable if defined?(ActionView::TemplateHandlers::Compilable)

    def compile(template)
      Xil::Engine.new(template).to_code
    end
  end

end

# Register PDF type 
Mime::Type.register("application/pdf", :pdf) unless defined? Mime::PDF
Mime::Type.register("application/vnd.oasis.opendocument.text", :odt) unless defined? Mime::ODT

# Register Template Handler
ActionView::Template.register_template_handler(:xpdf, Xil::TemplateHandler)
# ActionView::Template.register_template_handler(:xodt, Xil::TemplateHandler)

# Specify we don't want to use the layouts
ActionController::Base.exempt_from_layout :xpdf
