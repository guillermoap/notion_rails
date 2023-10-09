module NotionRails
  class BasePage
    include NotionRails::Renderers
    # TODO: validate object type is page
    attr_reader :id,
      :created_time,
      :last_edited_time,
      :created_by,
      :last_edited_by,
      :cover,
      :icon,
      :parent,
      :archived,
      :properties,
      :tags,
      :title,
      :slug,
      :url

    def initialize(data)
      @id = data['id']
      @created_time = data['created_time']
      @last_edited_time = data['last_edited_time']
      # TODO: handle user object
      @created_by = data['created_by']
      @last_edited_by = data['last_edited_by']
      # TODO: handle external type
      @cover = data['cover']
      # TODO: handle emoji type
      @icon = data['icon']
      # TODO: handle database_id type
      @parent = data['parent']
      @archived = data['archived']
      # TODO: handle properties object
      @properties = data['properties']
      process_properties
      @url = data['url']
    end

    def formatted_title(options = {})
      render_title(@title, options)
    end

    private

    def process_properties
      @tags = @properties['tags']
      @title = @properties.dig('name', 'title')
      @slug = @properties['slug']
    end
  end
end
