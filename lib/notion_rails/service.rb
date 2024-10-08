# frozen_string_literal: true

module NotionRails
  class Service
    class << self
      # Generates the default query for fetching pages
      # @param tag [String, nil] The tag to filter pages by, or nil to include all tags
      # @param slug [String, nil] The slug to filter pages by, or nil to include all slugs
      # @return [Array<Hash>] The default query to be used in the database query
      def default_query(tag: nil, slug: nil)
        query = [
          {
            property: 'public',
            checkbox: {
              equals: true
            }
          }
        ]

        if slug
          query.push({
            property: 'slug',
            rich_text: {
              equals: slug
            }
          })
        end

        if tag
          query.push({
            property: 'tags',
            multi_select: {
              contains: tag
            }
          })
        end

        query
      end

      # Provides the default sorting order for fetching pages
      # @return [Hash] The default sorting criteria for database queries
      def default_sorting
        {
          property: 'published',
          direction: 'descending'
        }
      end

      # Fetches a list of pages from Notion based on provided filters
      # @param tag [String, nil] The tag to filter pages by, or nil to include all tags
      # @param slug [String, nil] The slug to filter pages by, or nil to include all slugs
      # @param page_size [Integer] The number of pages to fetch per page
      # @return [Array<NotionRails::BasePage>] The list of pages as BasePage objects
      def get_pages(tag: nil, slug: nil, page_size: 10)
        __get_pages(tag: tag, slug: slug, page_size: page_size)['results'].map do |page|
          NotionRails::BasePage.new(page)
        end
      end

      # Fetches a single page by its ID
      # @param id [String] The ID of the page to fetch
      # @return [NotionRails::Page] The page as a NotionRails::Page object
      def get_page(id)
        base_page = NotionRails::BasePage.new(__get_page(id))
        base_blocks = get_blocks(id)
        NotionRails::Page.new(base_page, base_blocks)
      end

      # Fetches blocks associated with a given page ID
      # @param id [String] The ID of the page whose blocks are to be fetched
      # @return [Array<NotionRails::BaseBlock>] The list of blocks as BaseBlock objects
      def get_blocks(id)
        blocks = __get_blocks(id)
        parent_list_block_index = nil
        results = []
        blocks['results'].each_with_index do |block, index|
          block = refresh_block(block['id']) if refresh_image?(block)
          base_block = NotionRails::BaseBlock.new(block)
          base_block.children = get_blocks(base_block.id) if base_block.has_children
          if %w[numbered_list_item].include? base_block.type
            siblings = !parent_list_block_index.nil? &&
                       index != parent_list_block_index &&
                       base_block.type == results[parent_list_block_index]&.type &&
                       base_block.parent == results[parent_list_block_index]&.parent
            if siblings
              results[parent_list_block_index].siblings << base_block
              next
            else
              parent_list_block_index = results.length
            end
          else
            parent_list_block_index = nil
          end
          results << base_block
        end
        results
      end

      # Determines if an image block needs to be refreshed based on its expiry time
      # @param data [Hash] The data of the image block
      # @return [Boolean] True if the image needs to be refreshed, false otherwise
      def refresh_image?(data)
        return false unless data['type'] == 'image'
        return false unless data.dig('image', 'type') == 'file'

        expiry_time = data.dig('image', 'file', 'expiry_time')
        expiry_time.to_datetime.past?
      end

      private

      # Accessor for the client
      # @return [Notion::Client] The client instance used to interact with the Notion API
      def client
        @client ||= Notion::Client.new(token: NotionRails.config.notion_api_token)
      end

      # Retrieves pages from Notion using the client
      # @param tag [String, nil] The tag to filter pages by
      # @param slug [String, nil] The slug to filter pages by
      # @param page_size [Integer] The number of pages to fetch per page
      # @return [Hash] The response from the Notion API containing pages
      def __get_pages(tag: nil, slug: nil, page_size: 10)
        client.database_query(
          database_id: NotionRails.config.notion_database_id,
          sorts: [
            default_sorting
          ],
          filter: {
            'and': default_query(tag: tag, slug: slug)
          },
          page_size: page_size
        )
      end

      # Retrieves a single page by its ID from Notion
      # @param id [String] The ID of the page to fetch
      # @return [Hash] The response from the Notion API containing the page
      def __get_page(id)
        client.page(page_id: id)
      end

      # Retrieves blocks associated with a given ID from Notion, using cache if available
      # @param id [String] The ID of the block to fetch
      # @return [Hash] The response from the Notion API containing the blocks
      def __get_blocks(id)
        NotionRails.config.cache_store.fetch(id) { client.block_children(block_id: id) }
      end

      # Retrieves a single block by its ID from Notion
      # @param id [String] The ID of the block to fetch
      # @return [Hash] The response from the Notion API containing the block
      def __get_block(id)
        client.block(block_id: id)
      end

      # Refreshes a block by retrieving it again from Notion
      # @param id [String] The ID of the block to refresh
      # @return [Hash] The response from the Notion API containing the refreshed block
      def refresh_block(id)
        __get_block(id)
      end
    end
  end
end
