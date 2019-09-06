require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'active_support/inflector'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req = req 
    @res = res
    @already_built_response = false 
    @params = route_params.merge(req.params)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    if already_built_response? == false 
      res.status = 302 
      res.location = url
    else 
      raise "Double Render Error"
   end
  @already_built_response = true 
  session.store_session(@res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
   if already_built_response? == false 
    res.write(content)
    res['Content-Type'] = content_type
   else  
    raise "Double Render Error"
   end
   @already_built_response = true 
   session.store_session(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
      fname = File.dirname(__FILE__)
      file_path = File.join(fname, "..", "views", self.class.name.underscore, "#{template_name}.html.erb")
      file = File.read(file_path)
      erb = ERB.new(file).result(binding)
      render_content(erb, 'text/html')
      
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    if already_built_response?  == false
      render(name) 
    else
      nil
    end
  end
end

